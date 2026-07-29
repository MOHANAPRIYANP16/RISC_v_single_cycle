module risc_core (
	input clk,rst,
	input  [31:0] instruction,
	input  [31:0] read_data_mem,
	output [4:0]  address,
	output [31:0] write_data_mem,
    output  MemRead,MemWrite,	
	output [31:0] pc_out);
	
	wire [31:0]pc_update,pc_out_int,imm,write_data,
	           read_data_2,read_data_1,ALU_result,Branch_target;
	wire pc_src,Branch,Zero,reg_write,
		 ALUSrc,MemtoReg;
	wire [3:0]ALUControl;
	wire [1:0]ALUOp;
	wire [31:0]ALUSrc_out;
	
   pc pc_block (
   .clk(clk),
   .rst(rst),
   .next_pc(pc_update),
   .pc_out(pc_out_int)
   );
   
  pc_plus_4 plus_4(
  .pc_out(pc_out_int),
  .Branch_target(Branch_target),
  .pc_src(pc_src),
  .next_pc(pc_update)
  );
  
  PC_offset_adder offset_add ( 
  .PC(pc_out_int),
  .imm(imm),
  .Branch_target(Branch_target) ) ;
   
   register_file rf_block (
	.clk(clk),
    .rst(rst),
	.Read_register_1(instruction[19:15]),
	.Read_register_2(instruction[24:20]),
	.write_register(instruction[11:7]),
	.write_data(write_data),
	.reg_write(reg_write),
	.read_data_1(read_data_1) ,
	.read_data_2(read_data_2) );
	
   immediate_generator imm_gen (
	.instruction(instruction),
    .imm(imm));
  
   ALU alu_block (.a(read_data_1),
                  .b(ALUSrc_out),
			      .ALUControl(ALUControl),
		          .ALU_result(ALU_result),
			      .Zero(Zero));
	ALU_Control aluctrl_block (
					.ALUOp(ALUOp),
					.funct3(instruction[14:12]),
					.instruction(instruction[30]),//funct7 31 bit 
					.ALUControl(ALUControl));
					
	ALUSrc_mux alusrc_block(
					.imm(imm),
					.read_data_2(read_data_2),
	                .ALUSrc(ALUSrc),
	                .ALUSrc_out(ALUSrc_out));
	
    control_unit cu_block (.opcode(instruction[6:0]) , 
                           .ALUSrc(ALUSrc),
						   .MemtoReg(MemtoReg), 
						   .MemRead(MemRead), 
						   .Branch(Branch), 
						   .MemWrite(MemWrite), 
						   .RegWrite(reg_write) ,
                           .ALUOp(ALUOp)) ;
			
 assign write_data_mem = read_data_2;		
 assign write_data = MemtoReg ? read_data_mem :ALU_result;
 assign address = ALU_result[6:2]; 
 assign pc_src = Branch&Zero;
 assign pc_out = pc_out_int;
endmodule 