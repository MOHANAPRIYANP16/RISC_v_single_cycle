module instruction_memory (
	input [31:0] pc_out,
	output [31:0] instruction);
	
	reg [31:0] memory [0:255];
	
	initial
		$readmemb("instruction.mem",memory);
	
	assign instruction = memory[pc_out[31:2]];
	
endmodule