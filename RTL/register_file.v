module register_file (
	input clk,rst,
	input [4:0] Read_register_1,Read_register_2,
	input [4:0] write_register,
	input [31:0] write_data,
	input reg_write,
	output [31:0] read_data_1 ,read_data_2 );
	
	reg [31:0] memory [0:31];
	integer i;
	
	always @(posedge clk or negedge rst)
	begin
		if(!rst)
			for(i=0;i<32;i=i+1)	
				memory [i] <= 0;
		
		else if (reg_write && write_register != 5'd0)
			memory[write_register] <= write_data;
	end
	
		assign read_data_1 = memory[Read_register_1];
		assign read_data_2 = memory[Read_register_2];

endmodule
	
		