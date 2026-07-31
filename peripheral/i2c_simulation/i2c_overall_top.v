//     module i2c_overall_top #(
//     parameter SLAVE_ADDR = 7'h3C
//     ) (
// 	input   clk, 
//     input   rst,
// 	input   we,
// 	input [3:0] addr,
// 	input [31:0] wdata,
// 	output [31:0] rdata,
// 	inout  sda,
//     inout  scl,
// 	output err,
// 	output done,
// 	output busy);

//     pullup(sda);
//     pullup(scl);
    
//    // wire scl_wire,sda_wire;

//      i2c_top i2c_top(
// 			.clk(clk),
// 			.rst(rst),
// 			.we(we),
// 			.addr(addr),
// 			.wdata(wdata),
// 			.rdata(rdata),
// 			.err(err),
// 			.busy(busy),
// 			.done(done),
// 			.sda(sda),
//             .scl(scl));

//     i2c_slave_model #(
//         .SLAVE_ADDR(SLAVE_ADDR)
//     )  u_i2c_slave (
//         .scl(scl),
//         .sda(sda)
//     );

//     endmodule