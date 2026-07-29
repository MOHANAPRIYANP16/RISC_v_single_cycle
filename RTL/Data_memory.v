module Data_memory ( input clk ,rst ,
input  [4:0] address , 
input [31:0] write_data ,
input MemRead ,MemWrite ,
output [31:0] read_data );

integer i ;
reg [31:0]data_mem[0:31];

always@(posedge clk or negedge rst) 
begin 
	if(!rst)for ( i=0 ; i<32 ; i=i+1) data_mem[i]<= 0 ;
	else if (MemWrite && !MemRead) data_mem[address] <= write_data;
end 

assign  read_data = (MemRead && !MemWrite)? data_mem[address] : 32'd0;
endmodule 	

