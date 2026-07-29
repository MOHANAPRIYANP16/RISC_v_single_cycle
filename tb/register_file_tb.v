module register_file_tb;
	reg clk,rst;
	reg [4:0] Read_register_1,Read_register_2,write_register;
	reg [31:0] write_data;
	reg reg_write;
	wire [31:0] read_data_1,read_data_2;
	
	
	register_file uut (
	.clk(clk),
    .rst(rst),
	.Read_register_1(Read_register_1),
	.Read_register_2(Read_register_2),
	.write_register(write_register),
	.write_data(write_data),
	.reg_write(reg_write),
	.read_data_1(read_data_1) ,
	.read_data_2(read_data_2) );
	
	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end
	
	
	task reset ;
	integer i;
	begin
		@(negedge clk)
		rst = 0;
		@(negedge clk )
		rst = 1;
		@(posedge clk)
		#1;
		for(i=0;i<32;i=i+1)
		begin
			if(uut.memory[i] == 0)
				$display("memory got reseted");
			else 
			begin
				$display("memory not got reseted == %0t",$time);
				$stop;
			end
		end
	end
	endtask
	
	task initialize;
	begin
	    @(negedge clk)
		Read_register_1 = 5'd0;
		Read_register_2 = 5'd0;
		write_register  = 5'd0;
		write_data      = 5'd0;
		reg_write       = 5'd0;
	end
	endtask
	
	task write ;
	begin
		repeat(40)
		begin
			@(negedge clk)
			write_register = {$random}%32;
			write_data     = $urandom;
			reg_write      = 1'b1;
			@(posedge clk)
			#1;
			$display("write_register == %0d",write_register);
			$display("write_data == %0d",write_data);
			$display("memory_data == %0d",uut.memory[write_register]);
			
			if(write_register == 5'd0)
			begin
				if(uut.memory[write_register] == 32'd0)
				$display("x0 get passed");
				else
				begin
					$display("x0 is failed");
					$stop;
				end
			end
				
		   else if(write_data == uut.memory[write_register])
				$display("write passed"); 
			else
			begin
				$display("write is failed");
				$stop;
			end
		end
	end
	endtask

	task write_x0;
	begin
		@(negedge clk)
		write_register = 0;
		write_data     = $urandom;
		reg_write      = 1'b1;
		@(posedge clk)
		#1;
		$display("write_register == %0d",write_register);
		$display("write_data == %0d",write_data);
		$display("memory_data == %0d",uut.memory[write_register]);
		
		if(write_register == 5'd0)
		begin
			if(uut.memory[write_register] == 32'd0)
			$display("x0 get passed");
			else
			begin
				$display("x0 is failed");
				$stop;
			end
		end
	end
	endtask
		
	
	integer seed = 100;
	task read ;
	begin
		repeat(32)
		begin
			@(negedge clk)
			Read_register_1 = {$random}%32;
			Read_register_2 = {$random}%32;
			@(posedge clk)
			#1;
			$display("Read_register_1 == %0d",Read_register_1);
			$display("Read_register_2 == %0d",Read_register_2);
			$display("memory_data1 == %0d",uut.memory[Read_register_1]);
			$display("memory_data2 == %0d",uut.memory[Read_register_2]);
			$display("read_data_1 == %0d",read_data_1);
			$display("read_data_2 == %0d",read_data_2);
			
			if((uut.memory[Read_register_1] == read_data_1)&&(uut.memory[Read_register_2] == read_data_2))
				$display("read passed");
			else
			begin
				$display("read failed");
				$stop;
			end
		end
	end
	endtask
	
	initial begin
		reset;
		initialize;
	    write;
		write_x0;
		read;
		#10;
		$finish;
	end
	
	initial begin	
		$dumpfile("register_file.vcd");
		$dumpvars(0,register_file_tb);
	end
	endmodule
		
			
		 
	