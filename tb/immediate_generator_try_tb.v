module immediate_generator_tb ;
	reg [31:0] instruction;
	wire [31:0] imm;
	
	immediate_generator uut (instruction,imm);
	
	function [31:0] expected_imm;
		input [31:0] instr;
		reg [6:0] opcode;
	begin
		opcode = instr[6:0];
		
		case(opcode)
			7'b0010011,
			7'b0000011,
			7'b1100111 : expected_imm = {{20{instr[31]}},instr[31:20]};
			7'b0100011 : expected_imm = {{20{instr[31]}},instr[31:25],instr[11:7]};
			7'b1100011 : expected_imm = {{19{instr[31]}},instr[31],instr[7],instr[30:25],instr[11:8],1'b0};
			7'b0110111,
			7'b0010111 : expected_imm = {instr[31:12],12'd0};
			7'b1101111 : expected_imm = {{11{instr[31]}},instr[31],instr[19:12],instr[20],instr[30:21],1'b0};
			default    : expected_imm = 32'd0; 
		endcase
	end
	endfunction
	
	integer error_count;
	integer test_count;
	
	task check_imm ;
	input [31:0]instr;
	input [30*8:1] text_name ;
	reg [31:0] expected  ;
	begin
		instruction = instr;
		#1;
		expected =  expected_imm(instr);
		test_count = test_count +1;
		
		if(expected == imm)
			$display("passed [%0s] instr = %0h expected = %0h imm = %0h",text_name,instr,expected,imm);
		else
		begin
			$display("failed [%0s] instr = %0h expected = %0h imm = %0h",text_name,instr,expected,imm);
			error_count = error_count+1;
		end
	end
	endtask
	
	
	task directed_tests ;
	begin
		check_imm({12'd5,5'd8,3'd0,5'd1,7'b0010011},"I type positive");
		check_imm({12'd8,5'd3,3'd2,5'd2,7'b0000011},"lw positive");
		check_imm({12'd8,5'd5,3'd0,5'd1,7'b1100111},"jalr positive");
		check_imm({7'd0,5'd8,5'd1,3'd2,5'd8,7'b0100011},"sw positive");
		check_imm({1'b0,6'd0,5'd2,5'd1,3'd0,4'd4,1'b0,7'b1100011}, "B-type positive (BEQ)");
		check_imm({20'h12345, 5'd1, 7'b0110111}, "U-type (LUI)");
		check_imm({20'hFFFFF, 5'd1, 7'b0010111}, "U-type (AUIPC, all 1s)");
		check_imm({1'b0,10'd8,1'b0,8'd0,5'd1,7'b1101111}, "J-type positive (JAL)");
		check_imm({7'd0,5'd8,5'd6,3'd0,5'd5,7'b0110011},"R-type positive");
	end
	endtask
	
	
	task random;
	 integer i;
	 reg [6:0] valid_opcodes [0:5];
	 reg [31:0] instr;
        begin
            valid_opcodes[0] = 7'b0010011; // I-type (ADDI etc.)
            valid_opcodes[1] = 7'b0000011; // I-type (loads)
            valid_opcodes[2] = 7'b1100111; // I-type (JALR)
            valid_opcodes[3] = 7'b0100011; // S-type
            valid_opcodes[4] = 7'b1100011; // B-type
            valid_opcodes[5] = 7'b1101111; // J-type
			
	        for(i=0;i<40;i = i+1)
			begin
				instr = $urandom;
				instr[6:0] = valid_opcodes[{$random}%6];
				check_imm(instr,"RANDOM");
			end
		end
	endtask
	
	initial begin
		error_count = 0;
		test_count = 0;
		
		directed_tests;
		random;
		
	    $display("--------------------------------------------------");
        $display("TESTS RUN   : %0d", test_count);
        $display("TESTS FAILED: %0d", error_count);
		if(error_count == 0)
		
			$display("ALL test case passes");
		else
			$display("test case failed with error of %0d ",error_count);
		$finish;
	end
	
	initial begin
		$dumpfile("imm.vcd");
		$dumpvars(0,immediate_generator_tb);
	end
endmodule 

		
	
	
		
	