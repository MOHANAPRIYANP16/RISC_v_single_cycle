module i2c_top #(
    parameter SLAVE_ADDR = 7'h3C
) (
	input   clk, 
    input   rst,
	//input   we,
	//input [3:0] addr,
	//input [31:0] wdata,
	//output [31:0] rdata,
	inout sda,
	inout scl,
	output err,
	output done,
	output busy);
	
	wire scl_trig,phase_fall,phase_low,
		 phase_rise,phase_high,sda_oe,sda_in;
	wire  we;
	wire [3:0] addr;
	wire  [31:0] wdata;
	wire[31:0] rdata;
	vio_0 vio_inst (
    .clk(clk),

    // Inputs to VIO (signals observed in Hardware Manager)
    .probe_in0(rdata),
    // Outputs from VIO (signals driven from Hardware Manager)
    .probe_out0(wdata),
    .probe_out1(addr),
    .probe_out2(we)
); 
	
    scl_gen scl_block
	   (
		  .clk(clk),
		  .rst(rst),
		  .scl_fsm(scl_trig),
		  .output_scl(scl),
		  //.scl_hi(scl_hi),
		  .phase_fall(phase_fall),
		  .phase_low(phase_low),
		  .phase_rise(phase_rise),
		  .phase_high(phase_high)
	   );
	   
			 i2c i2c_block(
			.clk(clk),
			.rst(rst),
			.we(we),
			.phase_fall(phase_fall),
			.phase_low(phase_low),
			.phase_rise(phase_rise),
			.phase_high(phase_high),
			.addr(addr),
			.wdata(wdata),
			.rdata(rdata),
			.scl_trig(scl_trig),
			.sda_oe(sda_oe),
			.err(err),
			.busy(busy),
			.done(done),
			.sda_in(sda_in));

		
	
	
	    assign sda = sda_oe ? 1'b0:1'bz;
		assign sda_in = sda;

endmodule