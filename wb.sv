`ifndef WB_SV
`define WB_SV
`endif

`include "macros.sv"
//`include "Sysbus.defs"

module
wb
#(
	REGBITS =  5,//5 bits to identify the registers from the register file
  	LOGSIZE = 64 //64 bits to send the destination data to the register
)
(
	 input 	logic clk,//clock
	 input 	logic rst,//reset bit
	 input  logic [31:0] curr_pc,
	 //input logic ctrl_sig,
	 input 	logic [LOGSIZE-1:0] lddata_in,///the loaded data comes in here, in case it is a memory operation
	 input 	logic [LOGSIZE-1:0] alures_in,//the result comes in here, if it is an ALU operation
	 input	logic ld_or_alu, //logic bit to choose whether it is a ALU or a memory operation
	 input  logic is_ecall, //logic bit to classify an ECALL
	 input [LOGSIZE-1:0] ecall_reg_val [7:0], //logic to hold ECALL input values  
	 input  logic [REGBITS-1:0] rd_mem,//the destination register value from ALU and memory module should be specified here
	 input logic wb_flush, //flush input bit
	 output logic [LOGSIZE-1:0] data_out, //the output data would go to the register file
	 output logic [REGBITS-1:0] destReg, //the output register address would be held here
	 output logic ecall_flush, //flush output bit
	 output logic [31:0] pc_after_flush
);

logic [LOGSIZE-1:0] ecall_output;

	always_ff @ (posedge clk) begin //write on the positive edge of the clock
		//reset bit on, so clear the output data
		if (rst) begin 
			ecall_flush <= 0;
			data_out <= 64'b0;
			destReg	 <= 64'b0;
		end 
                else if(is_ecall) begin
			do_ecall(register_set[17],register_set[10],register_set[11],register_set[12],register_set[13],register_set[14],register_set[15],register_set[16],ecall_output);//call do_ecall
			//access the pc and send to the fetch stage
			ecall_flush <= 1;//set flush bit to use as no-op in previous states
			pc_after_flush <= curr_pc + 4;
			data_out <= ecall_output;//write ecall output
			destReg  <= 5'b01010; //set destination reg to a0
		end
		//write to the destination register value and the data value
		else begin
			ecall_flush <= 0;
			data_out <= ld_or_alu ? lddata_in : alures_in;
                        destReg	 <= wb_flush ? 5'b00000 : rd_mem;
		end
	end
endmodule
