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
    if ((data_from_mem[7:0] == 0) & pc != 0) begin
          $display("zero = %x", register_file[0]);
          $display("ra   = %x", register_file[1]);
          $display("sp   = %x", register_file[2]);
          $display("gp   = %x", register_file[3]);
          $display("tp   = %x", register_file[4]);
          $display("t0   = %x", register_file[5]);
          $display("t1   = %x", register_file[6]);
          $display("t2   = %x", register_file[7]);
          $display("s0   = %x", register_file[8]);
          $display("s1   = %x", register_file[9]);
          $display("a0   = %x", register_file[10]);
          $display("a1   = %x", register_file[11]);
          $display("a2   = %x", register_file[12]);
          $display("a3   = %x", register_file[13]);
          $display("a4   = %x", register_file[14]);
          $display("a5   = %x", register_file[15]);
          $display("a6   = %x", register_file[16]);
          $display("a7   = %x", register_file[17]);
          $display("s2   = %x", register_file[18]);
          $display("s3   = %x", register_file[19]);
          $display("s4   = %x", register_file[20]);
          $display("s5   = %x", register_file[21]);
          $display("s6   = %x", register_file[22]);
          $display("s7   = %x", register_file[23]);
          $display("s8   = %x", register_file[24]);
          $display("s9   = %x", register_file[25]);
          $display("s10  = %x", register_file[26]);
          $display("s11  = %x", register_file[27]);
          $display("t3   = %x", register_file[28]);
          $display("t4   = %x", register_file[29]);
          $display("t5   = %x", register_file[30]);
          $display("t6   = %x", register_file[31]);
          $finish;
    end

  end

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
    .opcode(decoder_opcode),
    .regDest(decoder_regDest),
    .clk(data_mem_valid)
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
