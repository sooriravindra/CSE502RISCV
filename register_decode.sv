//register_decode module
`include "instructions.sv"
module register_decode
#(
	REGBITS =  5,
	IMMREG  = 12,
	OPFUNC	= 10,
        UIMM    = 20,
	INSTRSZ = 32
)
(
    //general inputs
    input  clk,
    input  reset,
    input  [INSTRSZ - 1:0] instr,
    input  [63:0] prog_counter,
    input  wr_en,
    input  alu_st_dec,
    input  icache_fetch_miss,
    // specify the register number and data to write
    input  [4:0] destn_reg,
    input  [63:0] destn_data,
    input  [4:0] aluRegDest,   
    input  [4:0] memRegDest,   
    input  [4:0] wbRegDest,   
    input  is_mem_busy,
    //flush
    input decoder_flush,
    input dec_icache_hit,
    // output data
    output [63:0] rd_data_A,
    output [63:0] rd_data_B,
    // control logic
    output [REGBITS - 1:0]  reg_dest,
    output [UIMM - 1: 0]    uimm,
    output [INSTRSZ - 1: 0] imm32,
    output [OPFUNC - 1:0]   opcode,
    output [INSTRSZ - 1: 0] out_instr,
    output [INSTRSZ - 1: 0] curr_pc,
    output [REGBITS - 1: 0] regA,
    output [IMMREG - 1:0]   regB,
    output alustall,
    output dec_icache_hit_out,
    output is_mem_operation
);
    enum
    {
      opcodeR1 = 7'b0110011,
      opcodeR2 = 7'b0111011,
      opcodeI1 = 7'b1100111,
      opcodeI2 = 7'b0000011,
      opcodeI3 = 7'b0010011,
      opcodeI4 = 7'b0011011,
      opcodeS  = 7'b0100011,
      opcodeSB = 7'b1100011,
      opcodeU1 = 7'b0110111,
      opcodeU2 = 7'b0010111,
      opcodeUJ = 7'b1101111,
      opcodeFE = 7'b0001111,
      opcodeSY = 7'b1110011
    } OPS;

    logic[4:0] rd_reg_A;
    logic[4:0] rd_reg_B;
    logic[11:0] temp_regB;
    logic [OPFUNC -1:0] temp_opcode;
    logic [UIMM -1:0] temp_uimm;
    logic next_alustall, jmp_ctrl;
    logic [REGBITS - 1:0]  next_reg_dest;
    logic temp_is_mem_operation;

  always_comb begin
    OPS = instr[6:0];
    temp_regB   = instr[31:20];
    rd_reg_A    = 0;
    rd_reg_B    = 0;
    temp_is_mem_operation = 0;
    case(OPS)
        opcodeR1: begin
          //temp_opcode = "R";
          rd_reg_A    = instr[19:15];
          rd_reg_B    = instr[24:20];
          next_reg_dest    = (decoder_flush || alustall) ? 5'b00000 : instr[11:7];
          temp_opcode = { instr[14:12], instr[6:0] };
          case(instr[14:12])
              3'b000: begin
                  case(instr[31:25])
                      7'b0000000: begin
//                           $display("ADD rd, rs1, rs2");
                      end
                      7'b0100000: begin
//                           $display("SUB rd, rs1, rs2");
                      end
                      7'b0000001: begin
//                           $display("MUL rd, rs1, rs2");
                      end
                      default: $display("Unknown opcode\n");
                  endcase
              end
              3'b001: begin
                  case(instr[31:25])
                      7'b0000000: begin
//                           $display("SLL rd, rs1, rs2");
                      end
                      7'b0000001: begin
//                           $display("MULH rd, rs1, rs2");
                      end
                      default: $display("Unknown opcode\n");
                  endcase
              end
              3'b010: begin
                  case(instr[31:25])
                      7'b0000000: begin
//                           $display("SLT rd, rs1, rs2");
                      end
                      7'b0000001: begin
//                           $display("MULHSU rd, rs1, rs2");
                      end
                      default: $display("Unknown opcode\n");
                  endcase
              end
              3'b011: begin
                  case(instr[31:25])
                      7'b0000000: begin
//                           $display("SLTU rd, rs1, rs2");
                      end
                      7'b0000001: begin
//                           $display("MULHU rd, rs1,rs2");
                      end
                      default: $display("Unknown opcode\n");
                  endcase
              end
              3'b100: begin
                  case(instr[31:25])
                      7'b0000000: begin
//                           $display("XOR rd, rs1, rs2");
                      end
                      7'b0000001: begin
//                           $display("DIV rd, rs1, rs2");
                      end
                      default: $display("Unknown opcode\n");
                  endcase
              end
              3'b101: begin
                  case(instr[31:25])
                      7'b0000000: begin
//                           $display("SRL rd, rs1, rs2");
                      end
                      7'b0100000: begin
//                           $display("SRA rd, rs1, rs2");
                      end
                      7'b0000001: begin
//                           $display("DIVU rd, rs1, rs2");
                      end
                      default: $display("Unknown opcode\n");
                  endcase
              end
              3'b110: begin
                  case(instr[31:25])
                      7'b0000000: begin
//                           $display("OR rd, rs1, rs2");
                      end
                      7'b0000001: begin
//                           $display("REM rd, rs1, rs2");
                      end
                      default: $display("Unknown opcode\n");
                  endcase
              end
              3'b111: begin
                  case(instr[31:25])
                      7'b0000000: begin
//                           $display("AND rd, rs1, rs2");
                      end
                      7'b0000001: begin
//                           $display("REMU rd, rs1, rs2");
                      end
                      default: $display("Unknown opcode\n");
                  endcase
               end
               default: $display("Unknown opcode\n");
           endcase
       end
       opcodeR2: begin
          //temp_opcode = "R";
          rd_reg_A = instr[19:15];
          rd_reg_B = instr[24:20];
          next_reg_dest  = (decoder_flush || alustall) ? 5'b00000 :instr[11:7];
          temp_opcode = { instr[14:12] , instr[6:0] };
          case(instr[14:12])
              3'b000: begin
                  case(instr[31:25])
                      7'b0000000: begin
//                           $display("ADDW rd, rs1, rs2");
                      end
                      7'b0100000: begin
//                           $display("SUBW rd, rs1, rs2");
                      end
                      7'b0000001: begin
//                           $display("MULW rd, rs1, rs2");
                      end
                      default: $display("Unknown opcode\n");
                  endcase
              end
              3'b001: begin
//                  $display("SLLW rd, rs1, rs2");
              end
              3'b100: begin
//                  $display("DIVW rd, rs1, rs2");
              end
              3'b101: begin
                  case(instr[31:25])
                      7'b0000000: begin
//                           $display("SRLW rd, rs1, rs2");
                      end
                      7'b0100000: begin
//                           $display("SRAW rd, rs1, rs2");
                      end
                      7'b0000001: begin
//                           $display("DIVUW rd, rs1, rs2");
                      end
                      default: $display("Unknown opcode\n");
                  endcase
              end
              3'b110: begin
//                  $display("REMW rd, rs1, rs2");
              end
              3'b111: begin
//                  $display("REMUW rd, rs1, rs2");
              end
              default: $display("Unknown opcode\n");
          endcase
      end

      opcodeI2: begin
          //temp_opcode = "I";
          rd_reg_A    = instr[19:15];
          next_reg_dest    = (decoder_flush || alustall) ? 5'b00000 : instr[11:7];
          rd_reg_B    = instr[24:20];
          temp_opcode = { instr[14:12], instr[6:0] };
          temp_is_mem_operation = 1;
          case(instr[14:12])
              3'b000: begin
//                  $display("LB rd, %d(rs1)", $signed(instr[31:20]));
              end
              3'b001: begin
//                  $display("LH rd, %d(rs1)", $signed(instr[31:20]));
              end
              3'b010: begin
//                  $display("LW rd, %d(rs1)", $signed(instr[31:20]));
              end
              3'b011: begin
//                  $display("LD rd, %d(rs1)", $signed(instr[31:20]));
              end
              3'b100: begin
//                  $display("LBU rd, %d(rs1)", $signed(instr[31:20]));
              end
              3'b101: begin
//                  $display("LHU rd, %d(rs1)", $signed(instr[31:20]));
              end
              3'b110: begin
//                  $display("LWU rd, %d(rs1)", $signed(instr[31:20]));
              end
              default: $display("Unknown opcode\n");
          endcase
      end
      opcodeI3: begin
          rd_reg_A    = instr[19:15];
          rd_reg_B    = instr[24:20];
          next_reg_dest = (decoder_flush || alustall) ? 5'b00000 : instr[11:7];
          temp_opcode = { instr[14:12] , instr[6:0] };
          //temp_opcode = "I";
          case(instr[14:12])
              3'b000: begin
//                  $display("ADDI rd, rs1, %d", $signed(instr[31:20]));
              end
              //shift immediate instructions should only use lowest 5 bits
              //of the immediate value
              3'b001: begin
//                  $display("SLLI rd, rs1, %d", $signed(instr[25:20]));
              end
              3'b010: begin
//                  $display("SLTI rd, rs1, %d", $signed(instr[31:20]));
              end
              3'b011: begin
//                  $display("SLTIU rd, rs1, %d", $signed(instr[31:20]));
              end
              3'b100: begin
//                  $display("XORI rd, rs1, %d", $signed(instr[31:20]));
              end
              3'b101: begin
                  case(instr[30])
                      //shift immediate instructions should only use lowest 5 bits
                      1'b0: begin
//                          $display("SRLI rd, rs1, %x %x", $signed(instr[25:20]), instr);
                      end
                      1'b1: begin
//                          $display("SRAI rd, rs1, %d %x", $signed(instr[25:20]), instr);
                      end
                  endcase
              end
              3'b110: begin
//                  $display("ORI rd, rs1, %d", $signed(instr[31:20]));
              end
              3'b111: begin
//                  $display("ANDI rd, rs1, %d", $signed(instr[31:20]));
              end
          endcase
      end

      opcodeI4: begin
          rd_reg_A = instr[19:15];
          rd_reg_B    = instr[24:20];
          next_reg_dest  = (decoder_flush || alustall) ? 5'b00000 : instr[11:7];
          temp_opcode = { instr[14:12] , instr[6:0] };
          //temp_opcode = "I";
          case(instr[14:12])
              3'b000: begin
//                  $display("ADDIW rd, rs1, %d", $signed(instr[31:20]));
              end
              //shift instructions use lowest 5 bits for immediate
              3'b001: begin
//                  $display("SLLIW rd,rs1, %d", $signed(instr[24:20]));
              end
              3'b101: begin
                  case(instr[30])
                      //shift instructions use lowest 5 bits for immediate
                      0'b1: begin
//                          $display("SRLIW rd,rs1, %d", $signed(instr[24:20]));
                      end
                      1'b1: begin
//                          $display("SRAIW rd,rs1, %d", $signed(instr[24:20]));
                      end
                  endcase
              end
              default: $display("Unknown opcode\n");
          endcase
      end
      opcodeS: begin
        //temp_opcode = "S";
        rd_reg_A    = instr[19:15];
        rd_reg_B    = instr[24:20];
        next_reg_dest = (decoder_flush || alustall) ? 5'b00000 : instr[11:7];
        temp_opcode = { instr[14:12] , instr[6:0] };
        temp_is_mem_operation = 1;
        case(instr[14:12])
          3'b000: begin
//            $display("SB rs2, %d(rs1)", $signed({instr[31:25],instr[11:7]}));
          end
          3'b001: begin
//            $display("SH rs2, %d(rs1)", $signed({instr[31:25],instr[11:7]}));
          end
          3'b010: begin
//            $display("SW rs2, %d(rs1)", $signed({instr[31:25],instr[11:7]}));
          end
          3'b011: begin
//            $display("SD rs2, %d(rs1)", $signed({instr[31:25],instr[11:7]}));
          end
          default: $display("Unknown opcode\n");
        endcase
      end

      opcodeSB: begin
        //temp_opcode = "SB";
        rd_reg_A    = instr[19:15];
        rd_reg_B    = instr[24:20];
        next_reg_dest = (decoder_flush || alustall) ? 5'b00000 : instr[11:7];
        temp_opcode = { instr[14:12] , instr[6:0] };
        case(instr[14:12])
          3'b000: begin
//            $display("BEQ rs1, rs2, 0x%h",  $signed({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}));
          end
          3'b001: begin
//            $display("BNE rs1, rs2, 0x%h",  $signed({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}));
          end
          3'b100: begin
//            $display("BLT rs1, rs2, 0x%h",  $signed({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}));
          end
          3'b101: begin
//            $display("BGE rs1, rs2, 0x%h",  $signed({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}));
          end
          3'b110: begin
//            $display("BLTU rs1, rs2, 0x%h", $signed({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}));
          end
          3'b111: begin
//            $display("BGEU rs1, rs2, 0x%h", $signed({instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}));
          end
          default: $display("Unknown opcode\n");
        endcase
      end

      opcodeU1: begin
        //temp_opcode = "U";
        temp_uimm   = instr[31:12];
        next_reg_dest = (alustall || decoder_flush) ? 5'b00000 : instr[11:7];
        temp_opcode = {instr[14:12], instr[6:0]};
        rd_reg_A    = 0;
        rd_reg_B    = 0;
//        $display("LUI rd, 0x%h", $signed(instr[31:12]));
      end

      opcodeU2: begin
        //temp_opcode = "U";
        temp_uimm   = instr[31:12];
        next_reg_dest = (alustall || decoder_flush) ? 5'b00000 : instr[11:7];
        temp_opcode = {instr[14:12], instr[6:0]};
        rd_reg_A    = 0;
        rd_reg_B    = 0;
//        $display("AUIPC rd, 0x%h", $signed(instr[31:12]));
      end

      opcodeUJ: begin
        //temp_opcode = "UJ";
        next_reg_dest    = (alustall || decoder_flush) ? 5'b00000 : instr[11:7];
        temp_uimm   = {instr[31], instr[19:12], instr[20], instr[30:21]};
        temp_opcode = {instr[14:12], instr[6:0]};
        rd_reg_B    = 0;
        rd_reg_A    = 0;
//        $display("JAL rd, 0x%h", $signed({instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}));
      end

      opcodeI1: begin
          // temp_opcode = "I";
        next_reg_dest    = (alustall || decoder_flush) ? 5'b00000 : instr[11:7];
        temp_uimm   = 0;//{instr[31], instr[19:12], instr[20], instr[30:21]};
        temp_opcode = {instr[14:12], instr[6:0]};
        rd_reg_B    = instr[24:20];
        rd_reg_A    = instr[19:15];
//        $display("JALR rd, rs1, 0x%h", $signed(instr[31:20]));
      end

      opcodeFE: begin
        //temp_opcode = "FENCE AND FENCE.I";
        next_reg_dest    = 5'b00000;
        temp_opcode = {instr[14:12], instr[6:0]};
        rd_reg_A    = 5'b00000;
        rd_reg_B    = instr[24:20];
        case(instr[14:12])
          3'b000: begin
//            $display("FENCE 0x%h", $signed(rd_reg_B));
          end
          3'b001: begin
//            $display("FENCE 0x%h", $signed(rd_reg_B));
          end
        endcase
      end

      opcodeSY: begin
        next_reg_dest    = (decoder_flush || alustall) ? 5'b00000 : instr[11:7];
        rd_reg_A    = instr[19:15];
        rd_reg_B    = instr[24:20];
        temp_opcode = {instr[14:12], instr[6:0]};
        case(instr[14:12])
          3'b000: begin
//            $display("ECALL 0x%h", rd_reg_B);
          end
          3'b001: begin
//            $display("EBREAK 0x%h", rd_reg_B);
          end
          3'b010: begin
//            $display("CSRRW 0x%h", rd_reg_B);
          end
          3'b011: begin
//            $display("CSRRS 0x%h", rd_reg_B);
          end
          3'b100: begin
//            $display("CSRRC 0x%h", rd_reg_B);
          end
          3'b101: begin
//            $display("CSRRWI 0x%h", rd_reg_B);
          end
          3'b110: begin
//            $display("CSRRSI 0x%h", rd_reg_B);
          end
          3'b111: begin
//            $display("CSRRCI 0x%h", rd_reg_B);
          end
        endcase
      end

    endcase

    if (((aluRegDest == rd_reg_A || aluRegDest == rd_reg_B) && (aluRegDest != 0) && (alu_st_dec == 0)) 
    || ((memRegDest == rd_reg_A || memRegDest == rd_reg_B) && (memRegDest != 0)) 
    || ((wbRegDest == rd_reg_A || wbRegDest == rd_reg_B) && (wbRegDest != 0))
    || is_mem_busy)
  begin
      next_alustall = 0;
      if (!decoder_flush) begin
          next_alustall = 1;
      end
  end
  else begin
      next_alustall = 0;
  end
end

  always_ff @(posedge clk) begin //this always block is for write. we would write to the register in every postive edge of the clock
    if (reset) begin
      register_set[0] <= 64'b0;
      register_set[1] <= 64'b0;
      register_set[3] <= 64'b0;
      register_set[4] <= 64'b0;
      register_set[5] <= 64'b0;
      register_set[6] <= 64'b0;
      register_set[7] <= 64'b0;
      register_set[8] <= 64'b0;
      register_set[9] <= 64'b0;
      register_set[10]<= 64'b0;
      register_set[11]<= 64'b0;
      register_set[12]<= 64'b0;
      register_set[13]<= 64'b0;
      register_set[14]<= 64'b0;
      register_set[15]<= 64'b0;
      register_set[16]<= 64'b0;
      register_set[17]<= 64'b0;
      register_set[18]<= 64'b0;
      register_set[19]<= 64'b0;
      register_set[20]<= 64'b0;
      register_set[21]<= 64'b0;
      register_set[22]<= 64'b0;
      register_set[23]<= 64'b0;
      register_set[24]<= 64'b0;
      register_set[25]<= 64'b0;
      register_set[26]<= 64'b0;
      register_set[27]<= 64'b0;
      register_set[28]<= 64'b0;
      register_set[29]<= 64'b0;
      register_set[30]<= 64'b0;
      register_set[31]<= 64'b0;
    end
    else begin
      curr_pc <= prog_counter;
      out_instr <= instr;
      regA <= rd_reg_A;
      alustall <= next_alustall;
      regB     <= temp_regB;
      jmp_ctrl <= decoder_flush;
//      if (jmp_ctrl || !dec_icache_hit) begin
//        reg_dest <= 0;
//      end
//      else if (!jmp_ctrl && !dec_icache_hit) begin
//        reg_dest <= next_reg_dest;
//      end
//      else begin
//        reg_dest <= next_reg_dest;
//      end
      reg_dest <= (jmp_ctrl || icache_fetch_miss) ? 0: next_reg_dest;
//      reg_dest <= jmp_ctrl ? 0: next_reg_dest;
      dec_icache_hit_out <= dec_icache_hit;
      if (next_alustall || alustall) begin
        opcode    <=  10'h00f;
//        uimm      <= 0;
//        rd_data_A <= 0;
//        rd_data_B <= 0;
//        regB      <= 0;
        is_mem_operation <= 0;
        if (wr_en & destn_reg != 0) begin
            register_set[destn_reg] <= destn_data;
            register_set[0] <= 0;
        end
      end
      else begin
        is_mem_operation <= temp_is_mem_operation;
        uimm      <= temp_uimm;
        opcode    <= temp_opcode;
        rd_data_A <= register_set[rd_reg_A];
        rd_data_B <= register_set[rd_reg_B];
        if (wr_en & destn_reg != 0) begin
            register_set[destn_reg] <= destn_data; 
            register_set[0] <= 0;
        end
      end
    end
  end //always_ff block end
//  assign reg_dest = (jmp_ctrl || !dec_icache_hit) ? 0: next_reg_dest;

endmodule
