module control_unit ( input [6:0] opcode , 
output reg ALUSrc , MemtoReg , MemRead , Branch , MemWrite , RegWrite ,
output reg [1:0]ALUOp ) ;

always@(*) 
	begin 
		ALUSrc = 1'b0 ; 
		MemtoReg = 1'b0 ; 
		MemRead = 1'b0 ; 
		Branch = 1'b0 ; 
		MemWrite = 1'b0 ; 
		RegWrite = 1'b0 ; 
		ALUOp = 2'b00;
		case (opcode) 
			7'b0110011 : // r type 
						begin 
						RegWrite = 1'b1;
						ALUOp = 2'b10;
						end 
			7'b0010011 :// i type 
						begin 
						RegWrite = 1'b1;
						ALUSrc = 1'b1;
						ALUOp = 2'b11;
						end  
			7'b0000011 : // i type 
						begin 
						RegWrite = 1'b1;
						ALUSrc = 1'b1;
						ALUOp = 2'b00;
						MemRead = 1'b1 ; 
						MemtoReg = 1'b1 ; 
						end 
			7'b0100011 : // s type 
						begin 
						ALUOp = 2'b00;
						ALUSrc = 1'b1;
						MemWrite = 1'b1; 
						end
			7'b1100011 : // b type 
						begin 
						ALUOp = 2'b01;
						Branch = 1'b1; 
						end 
		endcase 
	end 

endmodule 