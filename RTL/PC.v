module pc(
  input clk,
  input rst,
  input next_pc [31:0],
  output pc_out [31:0]
);
always @(posedge clk  or negedge rst )
begin
      if(!rst)
        pc_out <= 32'h0000_0000;
        else
        pc_out <= next_pc;
end

endmodule