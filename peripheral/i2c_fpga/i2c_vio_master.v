module i2c (
	input   clk, 
	//input   scl_hi,
    input   rst,
	input   we,
	input   phase_low,
    input   phase_high,
    input   phase_fall,
	input   phase_rise,
	input [3:0] addr,
	input [31:0] wdata,
	output reg [31:0] rdata,
	output reg scl_trig,
	output reg sda_oe,
	output reg err,
	output reg busy,
	output reg done,
	input sda_in);
	
	
	reg [6:0] slv_addr;
	reg [7:0] tx_data;
	reg [4:0] state;
	reg [6:0] slv_reg;
	reg [2:0] bit_cnt;
	reg rwbar;
	reg [7:0] shift_reg;
	//reg [7:0] byte0_reg;   // holds first byte while reading second
	//reg       rd_two;      // 1 = read 2 bytes this transaction (e.g. LM75 temp reg)
	//reg       byte_sel; 
	
	
	localparam IDLE         = 5'd0,
			   START1       = 5'd1,	
			   START2       = 5'd2,
			   SLAVE_ADDR_W = 5'd3,
			   WAIT_ACK1    = 5'd4,
			   ACK1         = 5'd5,
			   REG_ADDR     = 5'd6,
			   WAIT_ACK2    = 5'd7,
			   ACK2         = 5'd8,
			   RESTART      = 5'd9,
			   SLAVE_ADDR_R = 5'd10,
			   WAIT_ACK3    = 5'd11,
			   ACK3         = 5'd12,
			   READDATA     = 5'd13,
			   WAIT_ACK4    = 5'd14,
			   ACK4         = 5'd15,
			   STOP1        = 5'd16,
			   STOP2        = 5'd17,
			   ERROR        = 5'd18;
	
		
reg we_d;

always @(posedge clk or posedge rst) begin
    if (rst)
        we_d <= 1'b0;
    else
        we_d <= we;
end

wire we_pulse = we & ~we_d;
	
	always @(posedge clk or posedge rst)
	begin
		if(rst)
		begin
			sda_oe   <= 0;
			rdata    <= 0;
			done     <= 1'b0;
			scl_trig <= 0; 
			state    <= IDLE;
			busy     <= 0;
			err      <= 0;
			shift_reg<= 0;
			bit_cnt  <= 0;
			slv_addr <= 0;
			rwbar    <= 0;
			tx_data  <= 0;
			done     <= 0;
			//byte0_reg<= 0;
			//rd_two   <= 0;
		//	byte_sel <= 0;
		end
		else begin
			
			if (we_pulse) begin
                case (addr)
                    4'h4:  begin slv_addr <= wdata[7:1]; rwbar <= wdata[0]; //rd_two <= wdata[8] 
					       end
                    4'h8:  tx_data  <= wdata[7:0];
                    4'h0: begin
                        if (wdata[0] && !busy) begin
                            busy    <= 1'b1;
                            state   <= START1;
							err     <= 0;
							done    <= 0;
                        end
                    end
                    default: begin end
                endcase
            end
			
			if (busy) begin
				case(state)
					START1 : begin
						sda_oe <= 0;
						scl_trig <= 1'b1;
						state <= START2;
					end
					
					START2 : begin
						if(phase_high)
						begin
							sda_oe    <= 1'b1;
							shift_reg <= {slv_addr,1'b0};
							bit_cnt   <= 3'd7;
							state     <= SLAVE_ADDR_W;
						end
					end
					
					SLAVE_ADDR_W : begin
					
						if (phase_low)
						begin
							sda_oe <= ~shift_reg[7];
						end
						
						else if(phase_rise)
						begin
							shift_reg <= {shift_reg[6:0], 1'b0};
							if (bit_cnt == 3'd0) state <= WAIT_ACK1;
                            else bit_cnt <= bit_cnt - 1;
						end
						
					end
					
					WAIT_ACK1 : begin
						if(phase_low)
					     state <= ACK1;
						end
					
					ACK1 : begin
						sda_oe <= 0;
						if(phase_high) begin
							if (sda_in)
								state <= ERROR;
							else begin
								shift_reg <= tx_data;
								bit_cnt   <= 3'd7;
								state     <= REG_ADDR;
							end
						end
					end
					
					REG_ADDR : begin
					    if(phase_low)
						begin
							sda_oe <= ~shift_reg[7];
							if (bit_cnt == 3'd0) state <= WAIT_ACK2;
                            else bit_cnt <= bit_cnt - 1;
						end
						else if(phase_rise)
						begin
							shift_reg <= {shift_reg[6:0], 1'b0};
							
						end
						
					end
					
					WAIT_ACK2 : begin
						if(phase_low)
					     state <= ACK2;
						end
					
					ACK2 : begin
					    sda_oe <= 0;
						if(phase_high)
						   state <= sda_in ? ERROR :RESTART;
						end

					// RESTART1 :
					// begin
					// 	if(phase_high)
					// 	begin
					// 		// Generate repeated START only
					// 		sda_oe <= 1'b1;
					// 		state  <= RESTART2;
					// 	end
					// end
					
					// RESTART2 :
					// begin
					// 	if(phase_low)
					// 	begin
					// 		shift_reg <= {slv_addr,rwbar};
					// 		bit_cnt   <= 3'd7;
					// 		state     <= SLAVE_ADDR_R;
					// 	end
					// end

					RESTART : begin
						if(phase_high)
						begin
							sda_oe    <= 1'b1;
							shift_reg <= {slv_addr,rwbar};
							bit_cnt   <= 3'd7;
							state     <= SLAVE_ADDR_R;
						end
					end
					
					SLAVE_ADDR_R : begin
						
						if (phase_low)
						begin
							sda_oe <= ~shift_reg[7];
							if (bit_cnt == 3'd0) state <= WAIT_ACK3;
                            else bit_cnt <= bit_cnt - 1;
						end
						else if(phase_rise)
						begin
							shift_reg <= {shift_reg[6:0], 1'b0};
							
						end
					end
					
					WAIT_ACK3 : begin
						if(phase_low)
					     state <= ACK3;
						end
					
					ACK3 : begin
						sda_oe <= 1'b0;
						if(phase_high)
						begin
						   state <= sda_in ? ERROR :READDATA;
						   bit_cnt <= 3'd7;
						   //byte_sel <= 1'b0;
						end
					end
					
					READDATA : begin
					    if(phase_low)
						begin
						    shift_reg <= {shift_reg[6:0], sda_in};
							if (bit_cnt == 3'd0) state <= WAIT_ACK4;
                            else bit_cnt <= bit_cnt - 1;
						end
					end
					
					WAIT_ACK4 : begin
						if(phase_low)
					     state <= ACK4;
						end
						
					ACK4 : begin
						//if (phase_low)
							sda_oe <= 1'b0;   // Release SDA = NACK

						if (phase_high) begin
							rdata <= {24'd0, shift_reg};
							state <= STOP1;
						end

					end
			
				/*	ACK4 : begin
						if (rd_two && !byte_sel) begin
							sda_oe <= 1'b1;          // drive ACK -- more bytes coming
							if (phase_high) begin
								byte0_reg <= shift_reg;
								bit_cnt   <= 3'd7;
								byte_sel  <= 1'b1;
								state     <= READDATA;  // go read the second byte
							end
						end else begin
							sda_oe <= 1'b0;           // release SDA = NACK (final byte)
							if (phase_high) begin
								rdata <= rd_two ? {16'd0, byte0_reg, shift_reg}
								                : {24'd0, shift_reg};
								state <= STOP1;
							end
						end
					end */
				
			        STOP1 : begin
						if(phase_rise)
							sda_oe <= 1;
						else if (phase_high)
						begin
							state <= STOP2;
							sda_oe <= 0;
						end
					end
					
					STOP2 : begin
						if (phase_high)
						begin
							busy  <= 1'b0;
							done  <= 1'b1; 
							state <= IDLE;
							scl_trig <= 0;
						end
					end
					
					ERROR : begin
						err <= 1;
						sda_oe <= 1'b0;
						state <= STOP1;
					end
				default : state <= IDLE;
			endcase
		    end
		end
	end
endmodule
	