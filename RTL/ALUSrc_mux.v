module ALUSrc_mux (
	input [31:0]imm,read_data_2,
	input ALUSrc,
	output [31:0]ALUSrc_out);
	
	assign ALUSrc_out = ALUSrc ? imm : read_data_2;
endmodule

	
	
	