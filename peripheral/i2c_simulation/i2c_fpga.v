// module i2c (
// 	input   clk, 
//     input   rst,
// 	input   start,
// 	input   phase_low,
//     input   phase_high,
//     input   phase_fall,
// 	input   phase_rise,
// 	input   read_or_write_bar,
// 	input [6:0] addr,
// 	input [31:0] wdata,
// 	output reg [31:0] rdata,
// 	output reg scl_trig;
// 	output sda_oe,
// 	input sda_in);
	
// 	reg [3:0] state;
// 	reg [6:0] slv_reg;
// 	reg [7:0] bit_cnt;
// 	reg rwbar;
// 	reg done ;
// 	reg [7:0] shift_reg
	
	
// 	localparam IDLE         = 4'd0,
// 			   START        = 4'd1,
// 			   SLAVE_ADDR_W = 4'd2,
// 			   ACK1         = 4'd3,
// 			   REG_ADDR     = 4'd4,
// 			   ACK2         = 4'd5,
// 			   RESTART      = 4'd6,
// 			   SLAVE_ADDR_R = 4'd7,
// 			   ACK3         = 4'd8,
// 			   RDATA        = 4'd9,
// 			   ACK4         = 4'd10,
// 			   STOP         = 4'd11;
	
	
// 	always @(posedge clk or negedge rst)
// 	begin
// 		if(!rst)
// 		begin
// 			sda_oe   <= 0;
// 			rdata    <= 0;
// 			done     <= 1'b0;
// 			scl_trig <= 0; 
// 		end
// 		else begin
			
// 			if (we) begin
//                 case (addr)
//                     4'h4:  begin slv_addr <= wdata[7:1]; rwbar <= wdata[0]; end
//                     4'h8:  tx_data  <= wdata[7:0];
//                     4'h10: div_reg  <= wdata;
//                     4'h0: begin
//                         if (wdata[0] && !busy) begin
//                             busy    <= 1'b1;
//                             ack_err <= 1'b0;
//                             state   <= IDLE;
//                         end
//                     end
//                     default: begin end
//                 endcase
//             end
			
// 			else begin
// 				case(state)
// 					IDLE : begin
// 						sda_oe <= 0;
// 						scl_trig <= 1'b1;
// 						state <= START;
// 					end
					
// 					START : begin
// 						if(phase_high)
// 						begin
// 							sda_oe <= 1'b1;
// 							shift_reg <= {slv_addr,rwbar);
// 							bit_cnt <= 4'd7;
// 							state   <= SLAVE_ADDR_W;
// 						end
// 					end
					
// 					SLAVE_ADDR_W : begin
						
// 					end
					
// 					ACK1 : begin
					
// 					end
					
// 					REG_ADDR : begin
					
// 					end
					
// 					ACK2 : begin
					
// 					end
					
// 					RESTART : begin
					
// 					end
					
// 					SLAVE_ADDR_R : begin
					
// 					end
					
// 					ACK3 : begin
					
// 					end
					
// 					RDATA : begin
					
// 					end
					
// 					ACK4 : begin
					
// 					end
				
// 			        STOP : begin
					
// 					end
		    
	
	