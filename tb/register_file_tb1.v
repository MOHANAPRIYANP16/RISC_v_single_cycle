`timescale 1ns/1ps

module register_file_tb;
    reg clk, rst;
    reg [4:0]  Read_register_1, Read_register_2, write_register;
    reg [31:0] write_data;
    reg        reg_write;
    wire [31:0] read_data_1, read_data_2;

    integer test_count;
    integer error_count;

    // ------------------------------------------------------------
    // Scoreboard / shadow model -- an independent prediction of what
    // each register SHOULD hold, maintained entirely in the testbench.
    // We check the DUT's outputs against THIS, never against
    // uut.memory directly -- that keeps the DUT a black box and means
    // the check is validating externally observable behavior, not
    // "does internal signal X match internal signal Y" (which proves
    // nothing about correctness if both were built the same wrong way).
    // ------------------------------------------------------------
    reg [31:0] expected_reg [0:31];

    register_file uut (
        .clk(clk),
        .rst(rst),
        .Read_register_1(Read_register_1),
        .Read_register_2(Read_register_2),
        .write_register(write_register),
        .write_data(write_data),
        .reg_write(reg_write),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ------------------------------------------------------------
    // Reset: drive it, then verify ALL 32 registers read back zero
    // through the actual read ports (black-box), updating the
    // shadow model to match.
    // ------------------------------------------------------------
    task do_reset;
        integer i;
        begin
            @(negedge clk) rst = 0;
            @(negedge clk) rst = 1;
            @(posedge clk) #1;

            for (i = 0; i < 32; i = i + 1)
                expected_reg[i] = 32'd0;

            for (i = 0; i < 32; i = i + 1) begin
                @(negedge clk)
                Read_register_1 = i;
                Read_register_2 = i;
                #1;
                test_count = test_count + 1;
                if (read_data_1 === 32'd0)
                    $display("PASS [reset] x%0d == 0", i);
                else begin
                    $display("FAIL [reset] x%0d == %h, expected 0", i, read_data_1);
                    error_count = error_count + 1;
                end
            end
        end
    endtask

    // ------------------------------------------------------------
    // Single reusable write task. Handles x0 automatically because
    // the shadow model applies the same hardwired-zero rule the DUT
    // is supposed to implement -- written independently here, not
    // copied from the DUT's if-condition.
    // ------------------------------------------------------------
    task do_write(input [4:0] addr, input [31:0] data);
        begin
            @(negedge clk)
            write_register = addr;
            write_data     = data;
            reg_write      = 1'b1;
            @(posedge clk)
            #1;
            reg_write = 1'b0;

            if (addr != 5'd0)
                expected_reg[addr] = data;
            // addr == 0 -> expected_reg[0] stays 0, matching x0's
            // hardwired-zero behavior -- no DUT internals consulted.

            $display("WRITE x%0d <= %h", addr, data);
        end
    endtask

    // ------------------------------------------------------------
    // Single reusable read+check task. Compares DUT output ports
    // against the shadow model -- this is the actual self-check.
    // ------------------------------------------------------------
    task do_read_check(input [4:0] addr1, input [4:0] addr2);
        begin
            @(negedge clk)
            Read_register_1 = addr1;
            Read_register_2 = addr2;
            #1;
            test_count = test_count + 1;

            if ((read_data_1 === expected_reg[addr1]) &&
                (read_data_2 === expected_reg[addr2]))
            begin
                $display("PASS [read] x%0d=%h  x%0d=%h",
                           addr1, read_data_1, addr2, read_data_2);
            end
            else begin
                $display("FAIL [read] x%0d: got=%h expected=%h | x%0d: got=%h expected=%h",
                           addr1, read_data_1, expected_reg[addr1],
                           addr2, read_data_2, expected_reg[addr2]);
                error_count = error_count + 1;
            end
        end
    endtask

    // ------------------------------------------------------------
    // Directed edge cases -- deterministic, run every single time,
    // targeting the specific corners a register file design tends
    // to get wrong.
    // ------------------------------------------------------------
    task directed_tests;
        begin
            // x0 must reject writes and always read as zero
            do_write(5'd0, 32'hDEADBEEF);
            do_read_check(5'd0, 5'd0);

            // x31 -- the other boundary register, easy to off-by-one
            do_write(5'd31, 32'hCAFEF00D);
            do_read_check(5'd31, 5'd31);

            // ordinary mid-range register
            do_write(5'd15, 32'h12345678);
            do_read_check(5'd15, 5'd0);

            // overwrite: second write to the same register must win
            do_write(5'd5, 32'h11111111);
            do_write(5'd5, 32'h22222222);
            do_read_check(5'd5, 5'd5);

            // both read ports pointed at the SAME register simultaneously
            do_write(5'd7, 32'hA5A5A5A5);
            do_read_check(5'd7, 5'd7);

            // reg_write deasserted -- a write attempt with reg_write=0
            // must NOT change the register
            @(negedge clk)
            write_register = 5'd10;
            write_data     = 32'hFFFFFFFF;
            reg_write      = 1'b0;
            @(posedge clk)
            #1;
            do_read_check(5'd10, 5'd10);   // expected_reg[10] still 0 -- untouched
        end
    endtask

    // ------------------------------------------------------------
    // Randomized regression -- broad coverage on top of the
    // directed corners above.
    // ------------------------------------------------------------
  task random_tests;
    integer i;
    reg [4:0] addr, prev_addr;
    reg [31:0] data;
    begin
        prev_addr = 5'd0;
        for (i = 0; i < 50; i = i + 1) begin
            addr = {$random} % 32;
            data = $urandom;
            do_write(addr, data);

            // rs1: verify the write that just happened
            // rs2: re-check the PREVIOUS write is still intact --
            //      a much stronger retention/isolation check than pure random
            do_read_check(addr, prev_addr);
            prev_addr = addr;
        end
    end
endtask

    initial begin
        test_count  = 0;
        error_count = 0;

        do_reset;
        directed_tests;
        random_tests;

        $display("--------------------------------------------------");
        $display("TESTS RUN   : %0d", test_count);
        $display("TESTS FAILED: %0d", error_count);
        if (error_count == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: %0d TEST(S) FAILED -- see FAIL lines above", error_count);
        $display("--------------------------------------------------");

        $finish;
    end

    initial begin
        $dumpfile("register_file.vcd");
        $dumpvars(0, register_file_tb);
    end

endmodule