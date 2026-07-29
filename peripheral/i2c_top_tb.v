`timescale 1ns/1ps
module tb_probe;
    reg clk = 0;
    reg rst = 1;
    reg we = 0;
    reg [3:0] addr = 0;
    reg [31:0] wdata = 0;
    wire [31:0] rdata;
    wire err, busy;
    wire sda, scl;
	wire done;

    pullup(sda);
    pullup(scl);

    i2c_top dut(
        .clk(clk), .rst(rst), .we(we), .addr(addr), .wdata(wdata),
        .rdata(rdata), .sda(sda), .scl(scl), .err(err), .busy(busy),.done(done)
    );

    always #5 clk = ~clk;

    integer toggles;
    initial toggles = 0;
    always @(scl) toggles = toggles + 1;

    initial begin
        #20 rst = 0;
        #20;
        // set slave addr = 7'h50, write op (rwbar=0)
        @(posedge clk); we=1; addr=7'h4; wdata = {24'd0, 7'h50, 1'b0}; @(posedge clk); we=0;
        // set tx_data (register pointer) = 8'hA0
        @(posedge clk); we=1; addr=7'h8; wdata = 32'h000000A0; @(posedge clk); we=0;
        // kick off transaction
        @(posedge clk); we=1; addr=7'h0; wdata = 32'h1; @(posedge clk); we=0;

        // Run for a generous window and report state
        #200000;
        $display("TIME=%0t busy=%b err=%b done = %0b scl_toggle_count=%0d rdata=%h", $time, busy, err, done,toggles, rdata);
        if (busy)
            $display("RESULT: STUCK - busy never cleared, transaction never completed");
        if (toggles == 0)
            $display("RESULT: SCL NEVER TOGGLED - clock generator never activated");
        $finish;
    end
    

    initial begin
        $dumpfile("i2c_top_tb.vcd");
        $dumpvars(0, tb_probe);
    end
endmodule