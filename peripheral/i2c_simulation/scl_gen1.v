


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2026 20:41:05
// Design Name: 
// Module Name: scl generator 
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module scl_gen 
(
   input  wire  clk,rst,
   output wire  output_scl,
                phase_fall,
                phase_low,
                phase_rise,
                phase_high,
				scl_fsm
				//scl_hi
);
parameter CLK_FREQUENCY = 100_000_000 ;
parameter SCL_FREQUENCY = 400_000;
parameter DIVIDER       = (CLK_FREQUENCY/SCL_FREQUENCY)/4; // 62.5 cycles the clock frequency is divided rounded to 62 
parameter divider_bits  = $clog2(DIVIDER);  // 6 bits width 

reg [1:0] phase;
reg [(divider_bits-1):0] count_400hz_62cycles; // 6 bit width register for counting 62 clock cycles 
reg scl_enable ;

wire count_trigger = (count_400hz_62cycles == (DIVIDER-1)) ;

always@(posedge clk or posedge rst )
begin
   if (rst)
   begin
      count_400hz_62cycles <= 0;
      scl_enable           <= 0;
      phase                <= 2'd3;
   end
   else if (scl_fsm)
   begin
      if (count_trigger)
      begin
         count_400hz_62cycles <= {divider_bits{1'b0}};
         phase                <= (phase == 2'd3) ? 2'b0 : phase +1'b1;
      end
      else  
         count_400hz_62cycles <= count_400hz_62cycles + 1'b1;

      if (phase_fall)
         scl_enable <= 1'b1;
      else if (phase_rise)
         scl_enable <= 1'b0;

   end
   else 
   begin
      scl_enable <= 1'b0;
      phase      <= 2'd3;   // ← reset to phase_high so first active phase is high
      count_400hz_62cycles <= 0;
   end
   
end
   assign phase_fall = (phase == 2'd0 && count_trigger);
   assign phase_low  = (phase == 2'd1 && count_trigger);
   assign phase_rise = (phase == 2'd2 && count_trigger);
   assign phase_high = (phase == 2'd3 && count_trigger);
   assign output_scl = scl_enable ? 1'b0 : 1'bz;
  // assign scl_hi     = scl_enable ? 1'b0 : 1'b1;
endmodule