// module i2c (
// 	input   clk, 
// 	input   scl_hi,
//     input   rst,
// 	input   we,
// 	input   phase_low,
//     input   phase_high,
//     input   phase_fall,
// 	input   phase_rise,
// 	input [6:0] addr,
// 	input [31:0] wdata,
// 	output reg [31:0] rdata,
// 	output reg scl_trig,
// 	output reg sda_oe,
// 	output reg err,
// 	output reg busy,
// 	input sda_in);
	
	
// 	reg [6:0] slv_addr;
// 	reg [7:0] tx_data;
// 	reg [3:0] state;
// 	reg [6:0] slv_reg;
// 	reg [2:0] bit_cnt;
// 	reg rwbar;
// 	reg done;
// 	reg [7:0] shift_reg;
	
	
// 	localparam IDLE         = 4'd0,
// 			   START1       = 4'd1,	
// 			   START2       = 4'd2,
// 			   SLAVE_ADDR_W = 4'd3,
// 			   ACK1         = 4'd4,
// 			   REG_ADDR     = 4'd5,
// 			   ACK2         = 4'd6,
// 			   RESTART      = 4'd7,
// 			   SLAVE_ADDR_R = 4'd8,
// 			   ACK3         = 4'd9,
// 			   READDATA     = 4'd10,
// 			   ACK4         = 4'd11,
// 			   STOP1        = 4'd12,
// 			   STOP2        = 4'd13,
// 			   ERROR        = 4'd14;
	
	
// 	always @(posedge clk or posedge rst)
// 	begin
// 		if(rst)
// 		begin
// 			sda_oe   <= 0;
// 			rdata    <= 0;
// 			done     <= 1'b0;
// 			scl_trig <= 0; 
// 			state    <= IDLE;
// 			busy     <= 0;
// 			err      <= 0;
// 			shift_reg<= 0;
// 			bit_cnt  <= 0;
// 			slv_addr <= 0;
// 			rwbar    <= 0;
// 			tx_data  <= 0;
// 			done     <= 0;
// 		end
// 		else begin
			
// 			if (we) begin
//                 case (addr)
//                     4'h4:  begin slv_addr <= wdata[7:1]; rwbar <= wdata[0]; end
//                     4'h8:  tx_data  <= wdata[7:0];
//                     4'h0: begin
//                         if (wdata[0] && !busy) begin
//                             busy    <= 1'b1;
//                             state   <= START1;
// 							err     <= 0;
// 							done    <= 0;
//                         end
//                     end
//                     default: begin end
//                 endcase
//             end
			
// 			if (busy && scl_hi) begin
// 				case(state)
// 					START1 : begin
// 						sda_oe <= 0;
// 						scl_trig <= 1'b1;
// 						state <= START2;
// 					end
					
// 					START2 : begin
// 						if(phase_high)
// 						begin
// 							sda_oe    <= 1'b1;
// 							shift_reg <= {slv_addr,1'b0};
// 							bit_cnt   <= 3'd7;
// 							state     <= SLAVE_ADDR_W;
// 						end
// 					end
					
// 					SLAVE_ADDR_W : begin
// 						if(phase_fall)
// 						begin
// 						sda_oe <= ~shift_reg[7];
// 						end
// 						else if (phase_low)
// 						begin
// 							shift_reg <= {shift_reg[6:0], 1'b0};
// 							if (bit_cnt == 3'd0) state <= ACK1;
//                             else bit_cnt <= bit_cnt - 1;
							
// 						end
// 					end
					
// 					ACK1 : begin
// 						sda_oe <= 0;
// 						if (phase_high) begin
// 							if (sda_in)
// 								state <= ERROR;
// 							else begin
// 								shift_reg <= tx_data;
// 								bit_cnt   <= 3'd7;
// 								state     <= REG_ADDR;
// 							end
// 						end
// 					end
					
// 					REG_ADDR : begin
// 						if(phase_fall)
// 						begin
// 							shift_reg <= {shift_reg[6:0], 1'b0};
							
// 						end
// 						else if(phase_low)
// 						begin
// 							sda_oe <= ~shift_reg[7];
// 							if (bit_cnt == 3'd0) state <= ACK2;
//                             else bit_cnt <= bit_cnt - 1;
// 						end
// 					end
					
// 					ACK2 : begin
// 					    sda_oe <= 0;
// 						if(phase_high)
// 						   state <= sda_in ? ERROR :RESTART;
// 						end
					
// 					RESTART : begin
// 						if(phase_high)
// 						begin
// 							sda_oe    <= 1'b1;
// 							shift_reg <= {slv_addr,rwbar};
// 							bit_cnt   <= 3'd7;
// 							state     <= SLAVE_ADDR_R;
// 						end
// 					end
					
// 					SLAVE_ADDR_R : begin
// 						if(phase_fall)
// 						begin
// 							shift_reg <= {shift_reg[6:0], 1'b0};
							
// 						end
// 						else if (phase_low)
// 						begin
// 							sda_oe <= ~shift_reg[7];
// 							if (bit_cnt == 3'd0) state <= ACK3;
//                             else bit_cnt <= bit_cnt - 1;
// 						end
// 					end
					
// 					ACK3 : begin
// 						sda_oe <= 1'b0;
// 						if(phase_high)
// 						begin
// 						   state <= sda_in ? ERROR :READDATA;
// 						   bit_cnt <= 3'd7;
// 						end
// 					end
					
// 					READDATA : begin
// 					    if(phase_low)
// 						begin
// 						    shift_reg <= {shift_reg[6:0], sda_in};
// 							if (bit_cnt == 3'd0) state <= ACK4;
//                             else bit_cnt <= bit_cnt - 1;
// 						end
// 					end
					
// 					ACK4 : begin
// 						//if (phase_low)
// 							sda_oe <= 1'b0;   // Release SDA = NACK

// 						if (phase_high) begin
// 							rdata <= {24'd0, shift_reg};
// 							state <= STOP1;
// 						end

// 					end
				
// 			        STOP1 : begin
// 						if(phase_rise)
// 							sda_oe <= 0;
// 						else if (phase_high)
// 						begin
// 							state <= STOP2;
// 							sda_oe <= 1;
// 						end
// 					end
					
// 					STOP2 : begin
// 						if (phase_high)
// 						begin
// 							busy  <= 1'b0;
// 							done  <= 1'b1;
// 							err   <= 1'b0;    
// 							state <= IDLE;
// 						end
// 					end
					
// 					ERROR : begin
// 						err <= 1;
// 						sda_oe <= 1'b0;
// 						state <= STOP1;
// 					end
// 				default : state <= IDLE;
// 			endcase
// 		    end
// 		end
// 	end
// endmodule
	