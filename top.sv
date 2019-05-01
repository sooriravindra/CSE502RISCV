`include "Sysbus.defs"
`include "fetch.sv"
//`include "wb.sv"
`include "memory.sv"

module top
#(
  REGSZ          = 5,
  INSTSZ         = 32,
  REGBSZ         = 12,
  WORDSZ         = 64,
  OPFUNC         = 10,
  BLOCKSZ        = 64*8,
  UIMM           = 20,
  BUS_TAG_WIDTH  = 13,
  BUS_DATA_WIDTH = 64
)
(
  input  clk,
         reset,

  // 64-bit addresses of the program entry point and initial stack pointer
  input  [WORDSZ - 1:0] entry,
  input  [WORDSZ - 1:0] stackptr,
  input  [WORDSZ - 1:0] satp,

  // interface to connect to the bus
  output bus_reqcyc,
  output bus_respack,
  output [BUS_DATA_WIDTH-1:0] bus_req,
  output [BUS_TAG_WIDTH-1:0]  bus_reqtag,
  input  bus_respcyc,
  input  bus_reqack,
  input  [BUS_DATA_WIDTH-1:0] bus_resp,
  input  [BUS_TAG_WIDTH-1:0]  bus_resptag
);

  logic got_inst, data_mem_valid, wr_data;

  logic [OPFUNC -1 : 0] decoder_opcode;
  logic [REGSZ - 1: 0] decoder_regDest;
  logic [UIMM - 1: 0] decoder_uimm;
  logic [REGBSZ - 1: 0] decoder_regB;
  logic [WORDSZ - 1:0] decoder_regA_val, decoder_regB_val;

  //connect alu output to register file input
  logic [63:0] alu_dataout;
  logic [REGSZ - 1:0]  alu_regDest;
  logic alu_wr_enable;


  logic [WORDSZ - 1: 0] pc, next_pc;
  logic [BLOCKSZ - 1: 0] data_from_mem;

  always_ff @ (posedge clk) begin
      if (reset) begin
          pc <= entry;
      end else begin
          pc <= next_pc;
      end
  end

  inc_pc pc_add(
    .pc_in(pc),
    .next_pc(next_pc),
    .sig_recvd(data_mem_valid)
  );

  memory_fetch memory_instance(
    .clk(clk),
    .rst(reset),
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
 /*
 cache instcache(
    .clk(clk),
    .wr_en(0),
    .data_in(0),
    .r_addr(pc),
    .w_addr(0),
    .rst(reset),
    .enable(data_mem_valid),
    .data_out(pc),
    .operation_complete(got_inst),
    .mem_address(mem_addr),
    .mem_data_out(data_out),
    .mem_wr_en(wr_data),
    .mem_data_in(0),
    .mem_data_valid(data_mem_valid)
 );

 cache datacache(
    .clk(clk),
    .wr_en(wr_data),
    .data_in(bus_resp),
    .r_addr(decoder_regA),
    .w_addr(decoder_regDest),
    .rst(reset),
    .enable(data_mem_valid),
    .data_out(dcache_data),
    .operation_complete(data_ready),
    .mem_address(mem_addr),
    .mem_data_out(data_out),
    .mem_wr_en(wr_data),
    .mem_data_in(data_in),
    .mem_data_valid(data_mem_valid)
 );
 */

 //instantiate decoder
 register_decode decoder_instance(
    .clk(clk),
    .reset(reset),
    .instr(data_from_mem[31:0]),
    .prog_counter(pc),
    .wr_en(alu_wr_enable),
    .destn_reg(alu_regDest),
    .destn_data(alu_dataout),
    .rd_data_A(decoder_regA_val),
    .rd_data_B(decoder_regB_val),
    .reg_dest(decoder_regDest),
    .uimm(decoder_uimm),
    .opcode(decoder_opcode),
    .regB(decoder_regB)
 );

 alu alu_instance(
    .regB(decoder_regB),
    .regA_value(decoder_regA_val),
    .regB_value(decoder_regB_val),
    .opcode(decoder_opcode),
    .regDest(decoder_regDest),
    .uimm(decoder_uimm),
    .clk(data_mem_valid),
    .aluRegDest(alu_regDest),
    .data_out(alu_dataout),
    .wr_en(alu_wr_enable)
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
