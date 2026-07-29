module pc_plus_4(
  input [31:0] pc_out,
  input [31:0] Branch_target,
  input pc_src,
  output[31:0] next_pc
);

assign next_pc = pc_src ? Branch_target : (pc_out + 4'd4);

endmodule