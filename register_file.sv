//register file module

module register_file(clk, reset, wrt_high_enable, rd_reg_A, rd_reg_B, destn_reg, destn_data, rd_data_A, rd_data_B, instr_bits, prog_counter);
	
	reg [63:0] register_set [31:0]; // set of all registers (32 registers of 64 bit each)
	input clk, reset, wrt_high_enable; //general inputs
	input [4:0] rd_reg_A, rd_reg_B, destn_reg; // specify the input and output registers
	input [63:0] destn_data, prog_counter; 
	output [63:0] rd_data_A, rd_data_B; //output data
	input [7:0] instr_bits;
	always_ff @(posedge clk) begin //this always block is for write. we would write to the register in every postive edge of the clock
		if (reset) begin
			 register_set[0] = 64'b0;
			 register_set[1] = 64'b0;
			 register_set[2] = 64'b0;
			 register_set[3] = 64'b0;
			 register_set[4] = 64'b0;
			 register_set[5] = 64'b0;
			 register_set[6] = 64'b0;
			 register_set[7] = 64'b0;
			 register_set[8] = 64'b0;
			 register_set[9] = 64'b0;
			 register_set[10] = 64'b0;
			 register_set[11] = 64'b0;
			 register_set[12] = 64'b0;
			 register_set[13] = 64'b0;
			 register_set[14] = 64'b0;
			 register_set[15] = 64'b0;
			 register_set[16] = 64'b0;	
			 register_set[17] = 64'b0;
			 register_set[18] = 64'b0;
			 register_set[19] = 64'b0;
			 register_set[20] = 64'b0;
			 register_set[21] = 64'b0;
			 register_set[22] = 64'b0;
			 register_set[23] = 64'b0;
			 register_set[24] = 64'b0;
			 register_set[25] = 64'b0;
			 register_set[26] = 64'b0;
			 register_set[27] = 64'b0;
			 register_set[28] = 64'b0;
			 register_set[29] = 64'b0;
			 register_set[30] = 64'b0;
			 register_set[31] = 64'b0;
		end if ((instr_bits[7:0] == 0) & prog_counter != 0) begin
         		 	$display("zero = %x", register_set[0]);
         		 	$display("ra   = %x", register_set[1]);
         		 	$display("sp   = %x", register_set[2]);
         		 	$display("gp   = %x", register_set[3]);
         		 	$display("tp   = %x", register_set[4]);
         		 	$display("t0   = %x", register_set[5]);
         		 	$display("t1   = %x", register_set[6]);
         		 	$display("t2   = %x", register_set[7]);
         		 	$display("s0   = %x", register_set[8]);
         		 	$display("s1   = %x", register_set[9]);
         		 	$display("a0   = %x", register_set[10]);
         		 	$display("a1   = %x", register_set[11]);
         		 	$display("a2   = %x", register_set[12]);
         		 	$display("a3   = %x", register_set[13]);
         		 	$display("a4   = %x", register_set[14]);
         		 	$display("a5   = %x", register_set[15]);
         		 	$display("a6   = %x", register_set[16]);
         		 	$display("a7   = %x", register_set[17]);
         		 	$display("s2   = %x", register_set[18]);
         		 	$display("s3   = %x", register_set[19]);
         		 	$display("s4   = %x", register_set[20]);
         		 	$display("s5   = %x", register_set[21]);
         		 	$display("s6   = %x", register_set[22]);
         		 	$display("s7   = %x", register_set[23]);
         		 	$display("s8   = %x", register_set[24]);
         		 	$display("s9   = %x", register_set[25]);
         		 	$display("s10  = %x", register_set[26]);
         			$display("s11  = %x", register_set[27]);
         		 	$display("t3   = %x", register_set[28]);
         		 	$display("t4   = %x", register_set[29]);
         		 	$display("t5   = %x", register_set[30]);
         		 	$display("t6   = %x", register_set[31]);
         		 	$finish;
   		 end else begin
			if (wrt_high_enable) begin
				register_set[destn_reg] <= destn_data; //write the data into the destination register
			end
		 end 
	end //always_ff block end

	//combinational read
	assign rd_data_A = register_set[rd_reg_A];//read the data from register A to data A
	assign rd_data_B = register_set[rd_reg_B];//read the data from register B to data B 

endmodule
