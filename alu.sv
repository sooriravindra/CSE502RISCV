//`include "Sysbus.defs"
module alu
(
    input [11:0] regB,
    input [9:0] opcode,
    input [4:0] regDest,
    input [19:0] uimm,
    input [31:0] i_pc,
    input [31:0] i_inst,

    input [63:0] regA_value,
    input [63:0] regB_value,
    input clk,
    input reset,
    output [63:0] data_out,
    output [4:0] aluRegDest,
    output [63:0] mem_out,
    output [63:0] alu_jmp_target,
    output is_jmp,
    output wr_en
);

enum {
    opcode_addi        = 10'h013,
    opcode_addiw       = 10'h01b,
    opcode_addsubmulw  = 10'h03b,
    opcode_andi        = 10'h393,
    opcode_slti        = 10'h113,
    opcode_sltiu       = 10'h193,
    opcode_xori        = 10'h213,
    opcode_ori         = 10'h313,
    opcode_addsubmul   = 10'h033,
    opcode_sllmulh     = 10'h0b3,
    opcode_sltmulhsu   = 10'h133,
    opcode_sltumulhu   = 10'h1b3,
    opcode_xordiv      = 10'h233,
    opcode_srlsradivu  = 10'h2b3,
    opcode_orrem       = 10'h333,
    opcode_andremu     = 10'h3b3,
    opcode_divw        = 10'h23b,
    opcode_srlsradivuw = 10'h2bb,
    opcode_remw        = 10'h33b,
    opcode_remuw       = 10'h3bb,
    opcode_slli        = 10'h093,
    opcode_srlsrai     = 10'h293,
    opcode_srlsraiw    = 10'h29b,
    opcode_slliw       = 10'h09b,
    opcode_sllw        = 10'h0bb,
    opcode_lui         = 10'b0000110111,
    opcode_auipc       = 10'b0000010111,
    opcode_jal         = 10'b0001101111,
    opcode_jalr        = 10'h067,
    opcode_beq         = 10'h063,
    opcode_bne         = 10'h0e3,
    opcode_blt         = 10'h263,
    opcode_bge         = 10'h2e3,
    opcode_bltu        = 10'h363,
    opcode_bgeu        = 10'h3e3,
    opcode_lb          = 10'h003,
    opcode_lh          = 10'h083,
    opcode_lw          = 10'h103,
    opcode_lbu         = 10'h203,
    opcode_lwu         = 10'h303,
    opcode_lhu         = 10'h283,
    opcode_sb          = 10'h023,
    opcode_sh          = 10'h0a3,
    opcode_sw          = 10'h123,
    opcode_ld          = 10'h183,
    opcode_sd          = 10'h1a3,
    opcode_fence       = 10'h00f,
    opcode_fencei      = 10'h08f,
    opcode_ecallebreak = 10'h073,
    opcode_csrrw       = 10'h0f3,
    opcode_csrrs       = 10'h173,
    opcode_csrrc       = 10'h1f3,
    opcode_csrrwi      = 10'h273,
    opcode_csrrsi      = 10'h373,
    opcode_csrrci      = 10'h3f3
} opcodes;

logic [63:0] temp_dest, quart_temp_dest, half_temp_dest, word_temp_dest, mem_dest;
logic sign_extend;
logic [31:0] auipc_word;
logic is_store, tmp_jmp;
logic[11:0] off_dest12;
logic[63:0] off_dest64, tmp_pc;
always_ff @(posedge clk) begin
    alu_jmp_target <= tmp_pc;
    is_jmp <= tmp_jmp;
    if (sign_extend && is_store == 0) begin
      data_out <= {{32{temp_dest[31]}}, temp_dest[31:0]};
      aluRegDest <= regDest;
      mem_out <= 0;
      wr_en <= 1;
    end
    else if (sign_extend == 0 && is_store == 0) begin
      data_out <= temp_dest;
      aluRegDest <= regDest;
      mem_out <= 0;
      wr_en <= 1;
    end
    else if (is_store) begin
      data_out <= temp_dest;
      aluRegDest <= 0;
      mem_out <= mem_dest;
      wr_en <= 1;
    end
end

always_comb begin
  is_store = 0;
  mem_dest = mem_out;
  off_dest12 = 0; 
  off_dest64 = 0; 
  quart_temp_dest = 0;
  half_temp_dest = 0; 
  word_temp_dest = 0;
  tmp_jmp = 0;
  tmp_pc = i_pc + 4;
  case (opcode)
/* After WP2 */
    opcode_lui  : begin
      temp_dest = $signed({uimm, 12'h000});
      sign_extend = 0;
    end
    opcode_auipc : begin
      auipc_word = {uimm, 12'h000};
      temp_dest = {{32{auipc_word[31]}}, auipc_word} + {32'h00000000, i_pc};
      sign_extend = 0;
    end
    opcode_jal : begin
      temp_dest =  i_pc + 4;
//      ret = {{11{uimm[19]}}, uimm} * 2;
      tmp_pc = i_pc + ({{11{uimm[19]}}, uimm} * 2);
      sign_extend = 0;
      tmp_jmp = 1;
    end
    opcode_jalr : begin
      temp_dest = i_pc + 4 + ({{52{regB[11]}}, regB} + regA_value);
//      retReg = register_enum.ra;
      sign_extend = 0;      
    end
    opcode_beq  : begin
      if (regA_value == regB_value) begin
        temp_dest = i_pc + {{19{regB[11]}}, regB, 1'b0};
      end
      else begin
        temp_dest = i_pc + 4;
      end
      sign_extend = 0;      
    end
    opcode_bne  : begin
      if (regA_value != regB_value) begin
        temp_dest = i_pc + {{19{regB[11]}}, regB, 1'b0};
      end
      else begin
        temp_dest = i_pc + 4;
      end
      sign_extend = 0;      
    end
    opcode_blt  : begin
      if ($signed(regA_value) < $signed(regB_value)) begin
        temp_dest = i_pc + {{19{regB[11]}}, regB, 1'b0};
      end
      else begin
        temp_dest = i_pc + 4;
      end
      sign_extend = 0;      
    end
    opcode_bge  : begin
      if ($signed(regA_value) >= $signed(regB_value)) begin
        temp_dest = i_pc + {{19{regB[11]}}, regB, 1'b0};
      end
      else begin
        temp_dest = i_pc + 4;
      end
      sign_extend = 0;      
    end
    opcode_bltu : begin
      if (regA_value < regB_value) begin
        temp_dest = i_pc + {{19{regB[11]}}, regB, 1'b0};
      end
      else begin
        temp_dest = i_pc + 4;
      end
      sign_extend = 0;      
    end
    opcode_bgeu : begin
      if (regA_value >= regB_value) begin
        temp_dest = i_pc + {{19{regB[11]}}, regB, 1'b0};
      end
      else begin
        temp_dest = i_pc + 4;
      end
      sign_extend = 0;      
    end
     
    opcode_lb   : begin
      quart_temp_dest = (regA_value + {{52{regB[11]}}, regB});
      temp_dest = {{56{quart_temp_dest[7]}}, quart_temp_dest[7:0]};
      sign_extend = 0;
    end      
    opcode_lh   : begin
      half_temp_dest = (regA_value + {{52{regB[11]}}, regB});
      temp_dest = {{48{half_temp_dest[15]}}, half_temp_dest[15:0]};
      sign_extend = 0;
    end      
    opcode_lw   : begin
      word_temp_dest = (regA_value + {{52{regB[11]}}, regB});
      temp_dest = {{32{word_temp_dest[31]}}, word_temp_dest[31:0]};
      sign_extend = 0;
    end      
    opcode_lbu : begin
      quart_temp_dest = (regA_value + {52'h0000000000000, regB});
      temp_dest = {24'h000000, quart_temp_dest};
      sign_extend = 0;
    end    
    opcode_lwu : begin
      temp_dest = (regA_value + {52'h0000000000000, regB});
      sign_extend = 0;
    end
    opcode_lhu  : begin
      half_temp_dest = (regA_value + {52'h0000000000000, regB});
      temp_dest = {16'h0000, half_temp_dest};
    end
    opcode_sb   : begin
      is_store = 1;
      off_dest12 = {regB[11:5], regDest};
      off_dest64 = {{52{off_dest12[11]}}, off_dest12};
      mem_dest   = regA_value + off_dest64;
      temp_dest  = $signed(regB_value[7:0]);
    end
    opcode_sh   : begin
      is_store = 1;
      off_dest12 = {regB[11:5], regDest};
      off_dest64 = {{52{off_dest12[11]}}, off_dest12};
      mem_dest   = regA_value + off_dest64;
      temp_dest  = $signed(regB_value[15:0]);
    end
    opcode_sw   : begin
      is_store = 1;
      off_dest12 = {regB[11:5], regDest};
      off_dest64 = {{52{off_dest12[11]}}, off_dest12};
      mem_dest   = regA_value + off_dest64;
      temp_dest  = $signed(regB_value[31:0]);
    end
    opcode_ld   : begin
      temp_dest = regA_value + {{52{regB[11]}}, regB};
    end
    opcode_sd   : begin
      is_store = 1;
      off_dest12 = {regB[11:5], regDest};
      off_dest64 = {{52{off_dest12[11]}}, off_dest12};
      mem_dest   = regA_value + off_dest64;
      temp_dest  = regB_value;
    end
    opcode_fence: begin
    end
    opcode_fencei : begin
    end
    opcode_ecallebreak : begin
//      if (regB[20] == 0) begin
//        do_ecall();
//      end
    end
    opcode_csrrw  : begin
    end
    opcode_csrrs  : begin
    end
    opcode_csrrc  : begin
    end
    opcode_csrrwi : begin
    end
    opcode_csrrsi : begin
    end
    opcode_csrrci : begin
    end
/* Until here */

    opcode_addi: begin
      temp_dest = regA_value + {{52{regB[11]}}, regB};
      sign_extend = 0;
      end
    opcode_addiw: begin
      temp_dest = regA_value[31:0] + {{20{regB[11]}}, regB};
      sign_extend = 1;
    end
    opcode_addsubmulw: begin
      case(regB[11:5])
        7'b0000000: begin
          temp_dest = regA_value[31:0] + regB_value[31:0];
          sign_extend = 1;
        end
        7'b0000001: begin
          temp_dest = regA_value[31:0] * regB_value[31:0];
          sign_extend = 1;
        end
        7'b0100000: begin
          temp_dest = regA_value[31:0] - regB_value[31:0];
          sign_extend = 1;
        end
      endcase
    end
    opcode_andi: begin
      temp_dest = regA_value & {{52{regB[11]}}, regB};
      sign_extend = 0;
    end
    opcode_slti: begin
      if ($signed(regA_value) < $signed({{52{regB[11]}}, regB})) begin
          temp_dest = 1;
      end else begin
          temp_dest = 0;
      end
      sign_extend = 0;
    end
    opcode_sltiu: begin
      if (regA_value < {{52{regB[11]}}, regB}) begin
          temp_dest = 1;
      end else begin
          temp_dest = 0;
      end
      sign_extend = 0;
    end
    opcode_xori: begin
      temp_dest = regA_value ^ {{52{regB[11]}}, regB};
      sign_extend = 0;
    end
    opcode_ori: begin
      temp_dest = regA_value | {{52{regB[11]}}, regB};
      sign_extend = 0;
    end
    opcode_addsubmul: begin
      case(regB[11:5])
        7'b0000000: begin
          temp_dest = regA_value + regB_value;
          sign_extend = 0;
        end
        7'b0000001: begin
          temp_dest = regA_value * regB_value;
          sign_extend = 0;
        end
        7'b0100000: begin
          temp_dest = regA_value - regB_value;
          sign_extend = 0;
        end
      endcase
    end
    opcode_sllmulh: begin
      case(regB[11:5])
        7'b0000000: begin
          temp_dest = regA_value << regB_value;
        end
        7'b0000001: begin
          logic [63:0] product = $signed(regA_value) * $signed(regB_value);
          temp_dest = product[63:32];
        end
      endcase
      sign_extend = 0;
    end
    opcode_sltmulhsu: begin
      case(regB[11:5])
        7'b0000000: begin
          if ($signed(regA_value) < $signed(regB_value)) begin
              temp_dest = 1;
          end else begin
              temp_dest = 0;
          end
        end
        7'b0000001: begin
          logic [63:0] product = $signed(regA_value) * regB_value;
          temp_dest = product[63:32];
        end
      endcase
      sign_extend = 0;
    end
    opcode_sltumulhu: begin
      case(regB[11:5])
        7'b0000000: begin
          if (regA_value < regB_value) begin
            temp_dest = 1;
          end else begin
            temp_dest = 0;
          end
        end
        7'b0000001: begin
          logic [63:0] product = regA_value * regB_value;
          temp_dest = product[63:32];
        end
      endcase
      sign_extend = 0;
    end
    opcode_xordiv: begin
        case(regB[11:5])
            7'b0000000: begin
                temp_dest = regA_value ^ regB_value;
                sign_extend = 0;
            end
            7'b0000001: begin
                temp_dest = $signed(regA_value) / $signed(regB_value);
                sign_extend = 0;
            end
        endcase
    end
    opcode_srlsradivu: begin
        case(regB[11:5])
            7'b0000000: begin
                temp_dest = regA_value >> regB_value;
                sign_extend = 0;
            end
            7'b0100000: begin
                temp_dest = $signed(regA_value) >> regB_value;
                sign_extend = 0;
            end
            7'b0000001: begin
                temp_dest = regA_value / regB_value;
                sign_extend = 0;
            end
        endcase
    end
    opcode_orrem: begin
        case(regB[11:5])
            7'b0000000: begin
                temp_dest = regA_value | regB_value;
                sign_extend = 0;
            end
            7'b0000001: begin
                temp_dest =$signed(regA_value) % $signed(regB_value);
                sign_extend = 0;
            end
        endcase
    end
    opcode_andremu: begin
        case(regB[11:5])
            7'b0000000: begin
                temp_dest = regA_value & regB_value;
                sign_extend = 0;
            end
            7'b0000001: begin
                temp_dest = regA_value % regB_value;
                sign_extend = 0;
            end
        endcase
    end
    opcode_divw: begin
        temp_dest = $signed(regA_value[31:0]) / $signed(regB_value[31:0]);
        sign_extend = 1;
    end
    opcode_srlsradivuw: begin
        case(regB[11:5])
            7'b0000000: begin
                temp_dest = regA_value[31:0] >> regB_value[31:0];
                sign_extend = 1;
            end
            7'b0100000: begin
                temp_dest = $signed(regA_value[31:0]) >> regB_value[31:0];
                sign_extend = 1;
            end
            7'b0000001: begin
                temp_dest = regA_value[31:0] / regB_value[31:0];
                sign_extend = 1;
            end
        endcase
    end
    opcode_remw: begin
        temp_dest = $signed(regA_value[31:0]) % $signed(regB_value[31:0]);
        sign_extend = 1;
    end
    opcode_remuw: begin
        temp_dest = regA_value[31:0] % regB_value[31:0];
        sign_extend = 1;
    end
    opcode_slli: begin
        temp_dest = regA_value << regB[4:0];
        sign_extend = 0;
    end
    opcode_srlsrai: begin
        case(regB[11:5])
            7'b0000000: begin
                temp_dest = regA_value >> regB[4:0];
                sign_extend = 0;
            end
            7'b0100000: begin
                temp_dest = $signed(regA_value) >> regB[4:0];
                sign_extend = 0;
            end
        endcase
    end
    opcode_srlsraiw: begin
        case(regB[11:5])
            7'b0000000: begin
                temp_dest = regA_value[31:0] >> regB[5:0]; // 6 bits immediate value
                sign_extend = 1;
            end
            7'b0100000: begin
                temp_dest = $signed(regA_value[31:0]) >> regB[5:0]; // 6 bits immediate value
                sign_extend = 1;
            end
        endcase
    end
    opcode_slliw: begin
        temp_dest = regA_value[31:0] << regB[5:0]; //6 bits immediate value
        sign_extend = 1;
    end
    opcode_sllw:begin
        temp_dest = regA_value[31:0] << regB_value[31:0];
        sign_extend = 1;
    end
    default: begin
    end
    endcase
end
endmodule

