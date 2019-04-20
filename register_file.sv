//register file module

module register_file(clk, wrt_high_enable, rd_reg_A, rd_reg_B, destn_reg, destn_data, rd_data_A, rd_data_B);
	
	logic [63:0] register_set [31:0]; // set of all registers (32 registers of 64 bit each)
	input clk, wrt_high_enable; //general inputs
	input [4:0] rd_reg_A, rd_reg_B, destn_reg; // specify the input and output registers
	input [63:0] destn_data; 
	output [63:0] rd_data_A, rd_data_B; //output data

	always_ff @(posedge clk) begin //this always block is for write. we would write to the register in every postive edge of the clock
		if (wrt_high_enable == 1) begin
			register_set[destn_reg] <= destn_data; //write the data into the destination register
		end 
	end //always_ff block end

	always_comb begin //combinational read
		if (wrt_high_enable == 0) begin
			assign rd_data_A = register_set[rd_reg_A];//read the data from register A to data A
			assign rd_data_B = register_set[rd_reg_B];//read the data from register B to data B 
		end
	end //always_comb block end

endmodule
