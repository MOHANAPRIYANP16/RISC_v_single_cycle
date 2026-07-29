module PC_offset_adder ( input [31:0] PC ,imm ,
output [31:0] Branch_target ) ;
assign Branch_target = PC + imm ;
endmodule 