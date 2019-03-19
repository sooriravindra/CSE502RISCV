`ifndef WB_SV
`define WB_SV

`include "registers.sv"
`include "macros.sv"

module
wb
#(
	REGBITS =  5,
  LOGSIZE = 64
)
(
	 input 	logic								clk,
	 input 	logic								rst,
	 input 	logic 							ctrl_sig,
	 input 	logic [LOGSIZE-1:0] lddata_in,
	 input 	logic [LOGSIZE-1:0] alures_in,
	 input	logic 							ld_or_alu,
	 input  logic [REGBITS-1:0]	rd,
	 output logic [LOGSIZE-1:0]	data_out,
	 output logic [LOGSIZE-1:0] destReg
);

	logic [LOGSIZE-1:0] temp_data;
	logic [REGBITS-1:0]	temp_reg;

	always_comb begin
		if (rd == 0) begin
			register_file[temp_reg] = 0;
		end
		else begin
			register_file[temp_reg] = data_out;
		end
	end
	always_ff @ (posedge clk) begin
		if (rst) begin
			data_out <= 0;
			destReg	 <= 0;
		end
		else begin
			data_out <= temp_data;
			destReg	 <= temp_reg; 
		end
	end
	always_comb begin
		temp_data = ld_or_alu ? lddata_in: alures_in;
		temp_reg	= rd;
	end
endmodule

`endif
