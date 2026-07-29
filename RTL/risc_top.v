module riscv_top (
	input clk,rst);
	
	wire  [31:0] instruction_top,
				 read_data_mem_top,
				 write_data_mem_top,
	             pc_out_top;
	wire  [4:0]  address_top;
	wire  MemRead_top,MemWrite_top;	
	
		risc_core core (
               .clk(clk),
			   .rst(rst),
	           .instruction(instruction_top),
	           .read_data_mem(read_data_mem_top),
	           .address(address_top),
	           .write_data_mem(write_data_mem_top),
               .MemRead(MemRead_top),
			   .MemWrite(MemWrite_top),	
               .pc_out(pc_out_top));
			   
		instruction_memory inst_mem (
			   .pc_out(pc_out_top),
			   .instruction(instruction_top));
		
		Data_memory data_mem (
				.clk(clk),
				.rst(rst) ,
				.address(address_top) , 
				.write_data(write_data_mem_top) ,
				.MemRead(MemRead_top) ,
				.MemWrite(MemWrite_top) ,
				.read_data(read_data_mem_top) );
endmodule
