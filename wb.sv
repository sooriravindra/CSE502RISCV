`ifndef WB_SV
`define WB_SV
`endif

`include "macros.sv"

module
wb
#(
	REGBITS =  5,//5 bits to identify the registers from the register file
  	LOGSIZE = 64 //64 bits to send the destination data to the register
)
(
	 input 	logic clk,//clock
	 input 	logic rst,//reset bit
	 //input logic ctrl_sig,
	 input 	logic [LOGSIZE-1:0] lddata_in,///the loaded data comes in here, in case it is a memory operation
	 input 	logic [LOGSIZE-1:0] alures_in,//the result comes in here, if it is an ALU operation
	 input	logic ld_or_alu, //logic bit to choose whether it is a ALU or a memory operation 
	 input  logic [REGBITS-1:0] rd_alu, rd_mem,//the destination register value from ALU and memory module should be specified here
	 output logic [LOGSIZE-1:0] data_out, //the output data would go to the register file
	 output logic [REGBITS-1:0] destReg //the output register address would be held here
);

	always_ff @ (posedge clk) begin //write on the positive edge of the clock
		//reset bit on, so clear the output data
		if (rst) begin 
			data_out <= 64'b0;
			destReg	 <= 64'b0;
		end
		//write to the destination register value and the data value
		else begin
			data_out <= ld_or_alu ? lddata_in : alures_in;
			destReg	 <= ld_or_alu ? rd_mem : rd_alu; 
		end
	end
endmodule
