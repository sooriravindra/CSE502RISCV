`ifndef _INSTRUCTIONS_SV
`define _INSTRUCTIONS_SV
`define OPLUI 	7'b0110111

`define OPAUIPC 7'b0010111

`define OPJAL 	7'b1101111
`define OPJALR 	7'b1100111

`define OPB 	7'b1100011  // For Branch instructions; BEQ, BNE, BLT, BGE, BLTU, BGEU

`define OPL 	7'b0000011  // For Load instructions; LB, LH, LW, LBU, LHU, LD, LWU

`define OPS 	7'b0100011  // For Store instructions; SB, SH, SW, SD

`define OPADDI 	7'b0110111

/* 
 *  Structure for instruction parameters
 */

//typedef struct {
//	logic[6:0] opcode;
//	logic[6:0] funct7;
//	logic[6:0] imm7;
//	logic[4:0] rd;
//	logic[4:0] rs1;
//	logic[4:0] rs2;
//	logic[2:0] funct3;
//	logic[11:0] imm12;
//	logic[4:0] imm5;
//	
//} dec_inst;
logic [63:0] register_set [31:0]; // (32 registers of 64 bit each) 
`endif
