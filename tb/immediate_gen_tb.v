`timescale 1ns/1ps

module immediate_generator_tb;

    reg  [31:0] instruction;
    wire [31:0] imm;
    integer     error_count;
    integer     test_count;

    immediate_generator uut (
        .instruction(instruction),
        .imm(imm)
    );

    // ------------------------------------------------------------
    // Golden reference model -- written independently from the
    // RISC-V spec, NOT copied from the DUT. If you copy the DUT's
    // logic here, any DUT bug gets silently duplicated and this
    // testbench will never catch it.
    // ------------------------------------------------------------
    function [31:0] expected_imm;
        input [31:0] instr;
        reg [6:0] op;
        begin
            op = instr[6:0];
            case(op)
                7'b0010011, 7'b0000011, 7'b1100111:                 // I-type
                    expected_imm = {{20{instr[31]}}, instr[31:20]};
                7'b0100011:                                          // S-type
                    expected_imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
                7'b1100011:                                          // B-type
                    expected_imm = {{19{instr[31]}}, instr[31], instr[7],
                                     instr[30:25], instr[11:8], 1'b0};
                7'b0110111, 7'b0010111:                               // U-type
                    expected_imm = {instr[31:12], 12'b0};
                7'b1101111:                                           // J-type
                    expected_imm = {{11{instr[31]}}, instr[31], instr[19:12],
                                     instr[20], instr[30:21], 1'b0};
                default:
                    expected_imm = 32'd0;
            endcase
        end
    endfunction

    // ------------------------------------------------------------
    // Checker task -- reports every mismatch, never stops early,
    // so one bug doesn't hide the rest of the report.
    // ------------------------------------------------------------
    task check_imm;
        input [31:0] instr;
        input [30*8:1] test_name;
        reg [31:0] expected;
        begin
            instruction = instr;
            #1;
            expected = expected_imm(instr);
            test_count = test_count + 1;
            if (imm === expected)
                $display("PASS [%0s] instr=%h  imm=%h", test_name, instr, imm);
            else begin
                $display("FAIL [%0s] instr=%h  imm=%h  expected=%h",
                           test_name, instr, imm, expected);
                error_count = error_count + 1;
            end
        end
    endtask

    // ------------------------------------------------------------
    // Directed tests -- built from named fields, not hand-typed hex,
    // so they're self-documenting and can't hide a transcription bug.
    // ------------------------------------------------------------
    task directed_tests;
        begin
            // I-type: positive immediate
            // addi x1, x0, 5
            check_imm({12'd5, 5'd0, 3'b000, 5'd1, 7'b0010011}, "I-type positive (ADDI)");

            // I-type: negative immediate -- tests sign extension
            // addi x1, x0, -1
            check_imm({12'hFFF, 5'd0, 3'b000, 5'd1, 7'b0010011}, "I-type negative (ADDI)");

            // I-type via load opcode
            // lw x2, -4(x3)
            check_imm({12'hFFC, 5'd3, 3'b010, 5'd2, 7'b0000011}, "I-type load (LW, negative)");

            // I-type via jalr opcode
            check_imm({12'd8, 5'd1, 3'b000, 5'd0, 7'b1100111}, "I-type JALR");

            // S-type: immediate split across two fields, positive
            // sw x2, 4(x1)
            check_imm({7'b0000000, 5'd2, 5'd1, 3'b010, 5'd4, 7'b0100011}, "S-type positive (SW)");

            // S-type: negative immediate, split fields + sign extension
            // sw x2, -4(x1)  -> imm = -4 = 12'hFFC -> [11:5]=1111111 [4:0]=11100
            check_imm({7'b1111111, 5'd2, 5'd1, 3'b010, 5'd28, 7'b0100011}, "S-type negative (SW)");

            // B-type: positive offset, must check LSB forced to 0
            // beq x1, x2, +8  -> imm[12:1] encodes 8 -> imm[3]=1, rest 0
            check_imm({1'b0, 6'b000000, 5'd2, 5'd1, 3'b000, 4'b0100, 1'b0, 7'b1100011}, "B-type positive (BEQ)");

            // B-type: negative offset -- tests sign extension AND LSB=0
            check_imm({1'b1, 6'b111111, 5'd2, 5'd1, 3'b000, 4'b1100, 1'b0, 7'b1100011}, "B-type negative (BEQ)");

            // U-type: low 12 bits must always be 0
            // lui x1, 0x12345
            check_imm({20'h12345, 5'd1, 7'b0110111}, "U-type (LUI)");

            // U-type via AUIPC
            check_imm({20'hFFFFF, 5'd1, 7'b0010111}, "U-type (AUIPC, all 1s)");

            // J-type: heavily scrambled bit order, LSB must be 0
            // jal x1, +16
            check_imm({1'b0, 10'b0000001000, 1'b0, 8'b00000000, 5'd1, 7'b1101111}, "J-type positive (JAL)");

            // J-type: negative offset -- sign extension across the scramble
            check_imm({1'b1, 10'b1111111111, 1'b1, 8'b11111111, 5'd1, 7'b1101111}, "J-type negative (JAL)");

            // Unhandled opcode (R-type) -- must hit default, return exactly 0
            check_imm({7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011}, "R-type (no immediate, expect 0)");
        end
    endtask

    // ------------------------------------------------------------
    // Randomized tests -- opcode constrained to the 6 valid types
    // so we're not wasting iterations on opcodes that always hit default.
    // ------------------------------------------------------------
    task random_tests;
        integer i;
        reg [6:0] valid_opcodes [0:5];
        reg [31:0] instr;
        begin
            valid_opcodes[0] = 7'b0010011; // I-type (ADDI etc.)
            valid_opcodes[1] = 7'b0000011; // I-type (loads)
            valid_opcodes[2] = 7'b1100111; // I-type (JALR)
            valid_opcodes[3] = 7'b0100011; // S-type
            valid_opcodes[4] = 7'b1100011; // B-type
            valid_opcodes[5] = 7'b1101111; // J-type

            for (i = 0; i < 200; i = i + 1) begin
                instr = $urandom;
                instr[6:0] = valid_opcodes[{$random} % 6];
                check_imm(instr, "random");
            end

            // also fuzz a few random UNKNOWN opcodes to confirm default=0 holds broadly
            for (i = 0; i < 20; i = i + 1) begin
                instr = $urandom;
                instr[6:0] = 7'b0110011; // R-type, always unhandled -> must be 0
                check_imm(instr, "random R-type (expect 0)");
            end
        end
    endtask

    initial begin
        error_count = 0;
        test_count  = 0;

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
        $dumpfile("immediate_generator.vcd");
        $dumpvars(0, immediate_generator_tb);
    end

endmodule