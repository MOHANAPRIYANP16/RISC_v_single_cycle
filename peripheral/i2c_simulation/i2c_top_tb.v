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
        .rdata(rdata),.err(err), .busy(busy),.done(done),.sda(sda),.scl(scl)
    );

    parameter SLAVE_ADDR = 7'h3C;
     i2c_slave_model #(
        .SLAVE_ADDR(SLAVE_ADDR)
    )  slave (
        .scl(scl),
        .sda(sda)
    );

    reg [13*8:1] state;  

    always #5 clk = ~clk;

    integer toggles;
    initial toggles = 0;
    always @(scl) toggles = toggles + 1;

     always @(dut.i2c_block.state)
		case(dut.i2c_block.state)
			5'b000 : state = "IDLE";
			5'b001 : state = "START1";
			5'b010 : state = "START2";
			5'b011 : state = "SLAVE_ADDR_W";
			5'b100 : state = "WAIT_ACK1";
			5'b101 : state = "ACK1";
			5'b110 : state = "REG_ADDR";
			5'b111 : state = "WAIT_ACK2";
            5'd8   : state = "ACK2";
            5'd9   : state = "RESTART";
            5'd10  : state = "SLAVE_ADDR_R";
            5'd11  : state = "WAIT_ACK3";
            5'd12  : state = "ACK3";
            5'd13  : state = "READDATA";
            5'd14  : state = "WAIT_ACK4";
            5'd15  : state = "ACK4";
            5'd16  : state = "STOP1";
            5'd17  : state = "STOP2";
            5'd18  : state = "ERROR";


			default : state = "IDLE";
		endcase

    initial begin
        #20 rst = 0;
        #20;
        // set slave addr = 7'h50, write op (rwbar=0)
        @(posedge clk); we=1; addr=7'h4; wdata = {24'd0, 7'h3C, 1'b1}; @(posedge clk); we=0;
        // set tx_data (register pointer) = 8'hA0
        @(posedge clk); we=1; addr=7'h8; wdata = 32'h00000002; @(posedge clk); we=0;
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