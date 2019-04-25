`include "Sysbus.defs"
`include "fetch.sv"
`include "decoder.sv"
//`include "wb.sv"
`include "memory.sv"

module top
#(
  BUS_DATA_WIDTH = 64,
  BUS_TAG_WIDTH = 13
)
(
  input  clk,
         reset,

  // 64-bit addresses of the program entry point and initial stack pointer
  input  [63:0] entry,
  input  [63:0] stackptr,
  input  [63:0] satp,
  
  // interface to connect to the bus
  output bus_reqcyc,
  output bus_respack,
  output [BUS_DATA_WIDTH-1:0] bus_req,
  output [BUS_TAG_WIDTH-1:0] bus_reqtag,
  input  bus_respcyc,
  input  bus_reqack,
  input  [BUS_DATA_WIDTH-1:0] bus_resp,
  input  [BUS_TAG_WIDTH-1:0] bus_resptag
);

  logic [4:0]  decoder_regA;
  logic [11:0] decoder_regB;
  logic [4:0]  decoder_regDest;
  logic [9:0]  decoder_opcode;
  logic [63:0] pc, next_pc; 
  logic [511:0] data_from_mem;
  logic data_mem_valid;
  
  always_ff @ (posedge clk) begin
    	if (reset) begin
        	pc <= entry;
    	end else begin
        	pc <= next_pc;
    	end
  end

  //connect alu output to register file input/output
  wire [63:0] data_wire, regA_val, regB_val;

  inc_pc pc_add(
    .pc_in(pc),
    .next_pc(next_pc),
    .sig_recvd(data_mem_valid)
    );

  memory_fetch memory_instace(
    .clk(clk),
    .in_address(pc),
    .data_out(data_from_mem),
    .data_valid(data_mem_valid),
    .bus_reqcyc(bus_reqcyc),
    .bus_respack(bus_respack),
    .bus_req(bus_req),
    .bus_reqtag(bus_reqtag),
    .bus_respcyc(bus_respcyc),
    .bus_reqack(bus_reqack),
    .bus_resp(bus_resp),
    .bus_resptag(bus_resptag)
  );

  decoder decoder_instance(
    .instr(data_from_mem[31:0]),
    .clk(data_mem_valid),
    .rs1(decoder_regA),
    .rs2(decoder_regB),
    .rd(decoder_regDest),
    .opcode(decoder_opcode)
  );

  alu alu_instance(
    .regA(decoder_regA),
    .regB(decoder_regB),
    .regA_value(regA_val),
    .regB_value(regB_val),
    .opcode(decoder_opcode),
    .regDest(decoder_regDest),
    .data_out(data_wire),
    .clk(data_mem_valid)
  );

  //instantiate register file
  register_file regfile_instance(
    .clk(clk),
    .reset(reset),
    .wrt_high_enable(wr_en),
    .rd_reg_A(decoder_regA),
    .rd_reg_B(decoder_regB[4:0]),
    .rd_data_A(regA_val),
    .rd_data_B(regB_val),
    .destn_reg(decoder_regDest),
    .destn_data(data_wire),
    .instr_bits(data_from_mem[7:0]),
    .prog_counter(pc)
  );

  /*
  wb wb_instance(
    .clk(clk),
    .rst(reset),
    .lddata_in(0),
    .alures_in(0),
    .ld_or_alu(0),
    .rd(decoder_regDest),
    .data_out(wb_dataOut),
    .destReg(wb_regDest)
  );
  */

endmodule
