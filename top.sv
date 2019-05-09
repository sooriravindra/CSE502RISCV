`include "Sysbus.defs"
`include "fetch.sv"
`include "wb.sv"
`include "memory_controller.sv"
`include "arbiter.sv"
`include "instructions.sv"
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

  logic data_mem_valid;
  logic wr_data;
  logic got_inst;
  logic [63:0] mem_addr;
  logic [63:0] icache_address;
  logic [63:0] dcache_address;
  logic mem_req;
  logic icache_req;
  logic dcache_req;

  logic [OPFUNC -1 : 0] decoder_opcode;
  logic [REGSZ - 1: 0] decoder_regDest;
  logic [UIMM - 1: 0] decoder_uimm;
  logic [REGBSZ - 1: 0] decoder_regB;
  logic [WORDSZ - 1:0] decoder_regA_val, decoder_regB_val, wr_to_mem;

  //connect alu output to writeback input
  logic [63:0] alu_dataout;
  logic [REGSZ - 1:0]  alu_regDest;
  logic alu_wr_enable;

  //connect wb output to decoder_register_file input
  logic [63:0] wb_dataOut, alu_target;
  logic [REGSZ - 1:0] wb_regDest;
  /*
   * alu write enable directly passed to the regfile,
   * and not passed through the write-back stage. do we need to pass this thru
   * write back stage?
   */
  
  //logic to for the wb stage to differentiate between ALU and memory ops
  logic ld_or_alu, top_jmp;

  logic [WORDSZ - 1: 0] pc, next_pc, curr_pc;
  logic [BLOCKSZ - 1: 0] data_from_mem;
  logic [BLOCKSZ - 1: 0] icache_data;
  logic [BLOCKSZ - 1: 0] dcache_data;
  logic [INSTSZ - 1: 0] icache_instr, alu_instr;

  logic icache_mem_req_complete;
  logic dcache_mem_req_complete;
  logic dcache_wren;

  always_ff @ (posedge clk) begin
      if (reset) begin
          pc <= entry;
          register_set[2] <= stackptr;
      end else begin
          pc <= next_pc;
      end
  end

  inc_pc pc_add(
    .pc_in(pc),
    .jmp_target(alu_target),
    .next_pc(next_pc),
    .is_jmp(top_jmp),
    .sig_recvd(got_inst)
  );

  memory_controller memory_controller_instance(
    .clk(clk),
    .rst(reset),
    .in_address(mem_addr),
    .start_req(mem_req),
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

 arbiter arbiter_instance(
     .clk(clk),
     .rst(reset),
    //input from caches
     .icache_address(icache_address),
     .dcache_address(dcache_address),
     .icache_req(icache_req),
     .dcache_req(dcache_req),
     .wr_en(dcache_wren),
     .data_in(dcache_dataout),
    // output to indicate operation complete to caches
     .icache_data_out(icache_data),
     .dcache_data_out(dcache_data), 
     .icache_operation_complete(icache_mem_req_complete),
     .dcache_operation_complete(dcache_mem_req_complete),

    //input from memory controller
     .data_from_mem(data_from_mem),
     .mem_data_valid(data_mem_valid),

    //output to memory controller
     .mem_address(mem_addr),
     .mem_data_out(data_to_mem),
     .mem_req(mem_req),
     .mem_wr_en(mem_wr_en)

 );

 cache instcache(
    .clk(clk),
    .wr_en(0),
    .data_in(0),
    .r_addr(pc),
    .w_addr(0),
    .rst(reset),
    .enable(clk),
    .data_out(icache_instr),
    .operation_complete(got_inst),
    .mem_address(icache_address),
    .mem_req(icache_req),
    .mem_data_in(icache_data),
    .mem_data_valid(icache_mem_req_complete)
 );

 /*
 cache datacache(
    .clk(clk),
    .wr_en(1),
    .data_in(bus_resp),
    .r_addr(decoder_regA),
    .w_addr(decoder_regDest),
    .rst(reset),
    .enable(data_mem_valid),
    .data_out(dcache_data),
    .operation_complete(data_ready),
    .mem_address(dcache_address),
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
    .instr(icache_instr),
    .prog_counter(pc),
    .wr_en(alu_wr_enable),
    .destn_reg(wb_regDest),
    .destn_data(wb_dataOut),
    .rd_data_A(decoder_regA_val),
    .rd_data_B(decoder_regB_val),
    .reg_dest(decoder_regDest),
    .uimm(decoder_uimm),
    .opcode(decoder_opcode),
    .curr_pc(curr_pc),
    .out_instr(alu_instr),
    .regB(decoder_regB),
    .ld_or_alu(ld_or_alu)
 );

 alu alu_instance(
    .regB(decoder_regB),
    .opcode(decoder_opcode),
    .regDest(decoder_regDest),
    .uimm(decoder_uimm),
    .i_pc(curr_pc),
    .i_inst(alu_inst),
    .regA_value(decoder_regA_val),
    .regB_value(decoder_regB_val),
    .reset(reset),
    .clk(clk),
    .data_out(alu_dataout),
    .aluRegDest(alu_regDest),
    .mem_out(wr_to_mem),
    .alu_jmp_target(alu_target),
    .is_jmp(top_jmp),
    .wr_en(alu_wr_enable)
 );

  memory memory_instance(
      .clk(clk),
      .rst(reset),
      .in_alu_result(alu_dataout),
      .regB_value(alu_regb_val),
      .is_store(alu_is_store),
      .is_load(alu_is_load),
      .data_out(mem_data_out)
  );

  wb wb_instance(
    .clk(clk),
    .rst(reset),
    .lddata_in(0),//load instructions not yet done. we need data cache to be in place for this
    .alures_in(alu_dataout),
    .ld_or_alu(ld_or_alu),
    .rd_alu(alu_regDest),//in case of an ALU operation
    .rd_mem(0), //in case of a memory opration, not done yet. This would be the deoder value passed through memory module 
    .data_out(wb_dataOut),
    .destReg(wb_regDest)
 );

endmodule
