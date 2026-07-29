module ALU_Control (
	input  [1:0]ALUOp,
	input  [2:0]funct3,
	input  instruction,//funct7 31 bit 
	output reg [3:0]ALUControl );
	
	
	parameter ADD  = 4'b0000,
			  SUB  = 4'b0001,
			  AND  = 4'b0010,
			  OR   = 4'b0011,
			  XOR  = 4'b0100,
			  SLL  = 4'b0101,
			  SRL  = 4'b0110,
			  SRA  = 4'b0111,
			  SLT  = 4'b1000,
			  SLTU = 4'b1001;
			   
			  
	
	always @(*)
	begin
		ALUcontrol = ADD;
		case(ALUOp)
			2'b00 : ALUControl = ADD; //0000  //lw,sw
			2'b01 : ALUControl = SUB; //0001  //BEQ
			2'b10 : begin   //R-type and I- type 
				case(funct3) 
					3'b000 : begin
						if(instruction)
							ALUControl = SUB; //0001
						else 
							ALUControl = ADD; // 0000
					end
					3'b001 : ALUControl = SLL; //0101
					3'b010 : ALUControl = SLT; //1000
					3'b011 : ALUControl = SLTU; //1001
					3'b100 : ALUControl = XOR; // 0100
					3'b101 : begin
						if(instruction)
							ALUControl = SRA; //0111
						else
							ALUControl = SRL;  //0110
					end
				    3'b110 : ALUControl = OR; // 0011
					3'b111 : ALUControl = AND; //0010
					default : ALUControl = ADD; //0010
				endcase
			end
			default : ALUControl = ADD; //0010
		endcase		
	end
endmodule
		
						
					
							
		