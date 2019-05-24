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
  logic data_ready;
  logic dcache_wr_en;
  logic wr_data;
  logic got_inst;
  logic [63:0] mem_addr;
  logic [63:0] icache_address;
  logic [63:0] dcache_address;
  logic [63:0] dcache_rd_addr;
  logic [63:0] dcache_wr_addr;
  logic mem_req;
  logic icache_req;
  logic dcache_req;

  logic [OPFUNC -1 : 0] decoder_opcode;
  logic [REGSZ - 1: 0] decoder_regDest, decoder_regA;
  logic [UIMM - 1: 0] decoder_uimm;
  logic [REGBSZ - 1: 0] decoder_regB;
  logic [WORDSZ - 1:0] decoder_regA_val, decoder_regB_val, wr_to_mem;

  //connect alu output to writeback input
  logic [63:0] alu_dataout;
  logic [63:0] mem_alu_dataout;
  logic [REGSZ - 1:0]  alu_regDest, mem_regDest;
  logic alu_wr_enable;

  //connect wb output to decoder_register_file input
  logic [63:0] wb_dataOut, alu_target;
  logic [REGSZ - 1:0] wb_regDest;
  logic [REGSZ - 1:0] mem_alu_regDest;
  /*
   * alu write enable directly passed to the regfile,
   * and not passed through the write-back stage. do we need to pass this thru
   * write back stage?
   */
  
  //logic to for the wb stage to differentiate between ALU and memory ops
  logic ld_or_alu, top_jmp, alu_stall, alu_is_store;
  //logic to detect and write 'ECALL' during writeback stage
  logic is_ecall_alu; 
  logic is_ecall_mem;
  logic alu_is_load;
  logic [WORDSZ - 1: 0] ecall_reg_set [7:0];

  logic [WORDSZ - 1: 0] next_decoder_pc, decoder_pc, pc, next_pc, curr_pc, pc_from_flush, pc_alu, pc_mem, pc_after_flush;
  logic [BLOCKSZ - 1: 0] data_from_mem;
  logic [BLOCKSZ - 1: 0] icache_data;
  logic [BLOCKSZ - 1: 0] dcache_data;
  logic [INSTSZ - 1: 0] icache_instr, alu_instr;

  logic icache_mem_req_complete;
  logic dcache_mem_req_complete;
  logic dcache_wren;
  logic top_flush, dec_out_got_inst;
  logic is_mem_busy;
  logic [BLOCKSZ-1:0] dcache_dataout;
  logic [63:0] mem_dcache_data;
  logic [63:0] mem_data_out;

  always_comb begin
      next_decoder_pc = pc;
  end
  always_ff @ (posedge clk) begin
      if (reset) begin
          pc <= entry;
          register_set[2] <= stackptr;
      end else begin
          if (got_inst) begin
              pc <= next_pc;
          end
          else begin
              pc <= next_decoder_pc;
          end
          decoder_pc <= next_decoder_pc;
      end
  end

  inc_pc pc_add(
    .pc_in(pc),
    .jmp_target(alu_target),
    .next_pc(next_pc),
    .is_jmp(top_jmp),
    .alu_stall(alu_stall),
    .sig_recvd(got_inst),
    .pc_from_flush(pc_after_flush),
    .fetch_flush(top_flush)
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
    .enable(!alu_stall),
    .data_out(icache_instr),
    .operation_complete(got_inst),
    .mem_address(icache_address),
    .mem_req(icache_req),
    .mem_data_in(icache_data),
    .mem_data_valid(icache_mem_req_complete),
    .mem_fetch(icache_mem_fetch)
 );

 cache datacache(
    .clk(clk),
    .wr_en(dcache_wr_en),
    .data_in(dcache_data_in),
    .r_addr(dcache_rd_addr),
    .w_addr(dcache_wr_addr),
    .rst(reset),
    .enable(is_mem_busy),
    .data_out(mem_dcache_data),
    .operation_complete(data_ready),
    .mem_address(dcache_address),
    .mem_data_out(dcache_dataout),
    .mem_wr_en(wr_data),
    .mem_req(dcache_req),
    .mem_data_in(dcache_data),
    .mem_data_valid(dcache_mem_req_complete)
 );

 //instantiate decoder
 register_decode decoder_instance(
    .clk(clk),
    .reset(reset),
    .instr(icache_instr),
    .prog_counter(decoder_pc),
    .wr_en(alu_wr_enable),
    .alu_st_dec(alu_is_store),
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
    .ecall_reg_val(ecall_reg_set),
    .regA(decoder_regA),
    .aluRegDest(alu_regDest),
    .memRegDest(mem_regDest),
    .wbRegDest(wb_regDest),
    .alustall(alu_stall),
    .decoder_flush(top_flush | top_jmp),
    .dec_icache_hit(got_inst),
    .dec_icache_hit_out(dec_out_got_inst),
    .icache_fetch_miss(icache_mem_fetch)
 );

 alu alu_instance(
    .regA(decoder_regA),
    .regB(decoder_regB),
    .opcode(decoder_opcode),
    .regDest(decoder_regDest),
    .uimm(decoder_uimm),
    .i_pc(curr_pc),
    .alu_store(alu_is_store),
    .i_inst(alu_inst),
    .regA_value(decoder_regA_val),
    .regB_value(decoder_regB_val),
    .reset(reset),
    .clk(clk),
    .data_out(alu_dataout),
    .is_ecall(is_ecall_alu),//wire the 'is_ecall' value
    .aluRegDest(alu_regDest),
    .mem_out(wr_to_mem),
    .alu_jmp_target(alu_target),
    .is_jmp(top_jmp),
    .wr_en(alu_wr_enable),
    .pc_from_alu(pc_alu),
    .alu_flush(top_flush | top_jmp),
    .alu_icache_hit(dec_out_got_inst),
    .alu_load(alu_is_load)
 );

  memory memory_instance(
      .clk(clk),
      .rst(reset),
      .in_alu_result(alu_dataout),
      .in_alu_rd(alu_regDest),
      .out_alu_rd(mem_alu_regDest),
      .regB_value(alu_regb_val),
      .is_store(alu_is_store),
      .is_load(alu_is_load),
      .is_ecall_alu(is_ecall_alu),
      .is_ecall_mem(is_ecall_mem),
      .data_out(mem_data_out),
      .curr_pc(pc_alu),
      .pc_from_mem(pc_mem),
      .reg_dest(mem_regDest),
      .memory_flush(top_flush),
      .is_mem_busy(is_mem_busy),
      .out_alu_result(mem_alu_dataout),
      .cache_operation_complete(data_ready),
      .cache_wr_en(dcache_wr_en),
      .cache_wr_addr(dcache_wr_addr),
      .cache_rd_addr(dcache_rd_addr),
      .cache_wr_value(dcache_data_in),
      .cache_data(mem_dcache_data),
      .ld_or_alu(ld_or_alu)
  );

  wb wb_instance(
    .clk(clk),
    .rst(reset),
    .lddata_in(mem_data_out),
    .alures_in(mem_alu_dataout),
    .ld_or_alu(ld_or_alu),
    .rd_alu(mem_alu_regDest),//in case of an ALU operation
    .rd_mem(mem_regDest), //in case of a memory opration
    .data_out(wb_dataOut),
    .is_ecall(is_ecall_mem),//wire the 'is_ecall' value to wb stage
    .destReg(wb_regDest),
    .ecall_reg_val(ecall_reg_set),
    .curr_pc(pc_mem),
    .pc_after_flush(pc_after_flush),
    .ecall_flush(top_flush),
    .wb_flush(top_flush)
 );

endmodule
