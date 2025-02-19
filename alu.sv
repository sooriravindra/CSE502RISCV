//`include "Sysbus.defs"
module alu
(
    input [4:0] regA,
    input [11:0] regB,
    input [9:0] opcode,
    input [4:0] regDest,
    input [19:0] uimm,
    input [63:0] i_pc,
    input [31:0] i_inst,

    input [63:0] regA_value,
    input [63:0] regB_value,
    input clk,
    input reset,
    input alu_flush, //flush the pipeline
    input alu_icache_hit,
    output [63:0] data_out,
    output [4:0] aluRegDest,
    output is_ecall,//the ECALL bit is set to zero in all normal cases.
    output [63:0] mem_out,
    output [63:0] alu_jmp_target,
    output is_jmp,
    output alu_store,
    output wr_en,
    output alu_load,
    output [5:0] mem_datasize,
    output load_sign_extend,
    output [31:0] pc_from_alu
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
    opcode_lui         = 10'b???0110111,
    opcode_auipc       = 10'b???0010111,
    opcode_jal         = 10'b???1101111,
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
logic is_store, tmp_jmp, is_load;
logic[11:0] off_dest12;
logic[63:0] off_dest64, tmp_pc, tmp_jalr;
logic next_load_extend;
logic [4:0] temp_regDest;
enum_datasize temp_datasize;
always_ff @(posedge clk) begin
  if(reset) begin
    //reset pc
    pc_from_alu <= 0;
  end 
  else begin
    //propagate pc
    pc_from_alu <= i_pc;
    if (tmp_jmp) begin
        alu_jmp_target <= tmp_pc;
    end
    else begin
        alu_jmp_target <= 0;
    end
    is_jmp <= tmp_jmp;
    alu_store <= is_store;
    alu_load <= is_load;
    mem_datasize <= temp_datasize;
    load_sign_extend <= next_load_extend;
        
    if (sign_extend && is_store == 0) begin
      data_out <= {{32{temp_dest[31]}}, temp_dest[31:0]};
      aluRegDest <= (opcode == opcode_fence || alu_flush) ? 0 : temp_regDest;
      mem_out <= 0;
      wr_en <= 1;
    end 
    else if (sign_extend == 0 && is_store == 0) begin
      data_out <= temp_dest;
      aluRegDest <= (opcode == opcode_fence || alu_flush) ? 0 : temp_regDest;
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
end

always_comb begin
  temp_regDest = regDest;
  temp_datasize = 0;
  is_store = 0;
  is_load = 0;
  mem_dest = mem_out;
  off_dest12 = 0; 
  off_dest64 = 0; 
  quart_temp_dest = 0;
  half_temp_dest = 0; 
  word_temp_dest = 0;
  tmp_jmp = 0;
  temp_dest = 0;
  sign_extend = 0;
  tmp_pc = i_pc + 4;
  is_ecall = 0;
  next_load_extend = 0;
  casex (opcode)
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
      tmp_pc = i_pc + (({{43{uimm[19]}}, uimm} * 2));
      sign_extend = 0;
      tmp_jmp = 1;
    end
    opcode_jalr : begin
      temp_dest = i_pc + 4;
      tmp_jalr = ({{52{regB[11]}}, regB} + regA_value);
      tmp_pc = {tmp_jalr[63:1], 1'b0};
      tmp_jmp = 1;
      sign_extend = 0;      
    end
    opcode_beq  : begin
      if (regA_value == regB_value) begin
        tmp_jmp = 1;
        tmp_pc = i_pc + ({{52{regB[11]}}, regDest[0], regB[10:5], regDest[4:1], 1'b0});
      end
      temp_regDest = 0;
      sign_extend = 0;      
    end
    opcode_bne  : begin
      if (regA_value != regB_value) begin
          tmp_pc = i_pc + ({{52{regB[11]}}, regDest[0], regB[10:5], regDest[4:1], 1'b0});
        tmp_jmp = 1;
      end
      temp_regDest = 0;
      sign_extend = 0;      
    end
    opcode_blt  : begin
      if ($signed(regA_value) < $signed(regB_value)) begin
          tmp_pc = i_pc + ({{52{regB[11]}}, regDest[0], regB[10:5], regDest[4:1], 1'b0});
          tmp_jmp = 1;
      end
      temp_regDest = 0;
      sign_extend = 0;      
    end
    opcode_bge  : begin
      if ($signed(regA_value) >= $signed(regB_value)) begin
          tmp_pc = i_pc + ({{52{regB[11]}}, regDest[0], regB[10:5], regDest[4:1], 1'b0});
        tmp_jmp = 1;
      end
      temp_regDest = 0;
      sign_extend = 0;      
    end
    opcode_bltu : begin
      if (regA_value < regB_value) begin
          tmp_pc = i_pc + ({{52{regB[11]}}, regDest[0], regB[10:5], regDest[4:1], 1'b0});
        tmp_jmp = 1;
      end
      temp_regDest = 0;
      sign_extend = 0;      
    end
    opcode_bgeu : begin
      if (regA_value >= regB_value) begin
          tmp_pc = i_pc + ({{52{regB[11]}}, regDest[0], regB[10:5], regDest[4:1], 1'b0});
        tmp_jmp = 1;
      end
      temp_regDest = 0;
      sign_extend = 0;
    end
     
    opcode_lb   : begin
      is_load = 1;
      temp_dest = (regA_value + {{52{regB[11]}}, regB});
      sign_extend = 0;
      temp_datasize = DATA_8;
      next_load_extend = 1;
    end
    opcode_lh   : begin
      is_load = 1;
      temp_dest = (regA_value + {{52{regB[11]}}, regB});
      sign_extend = 0;
      temp_datasize = DATA_16;
      next_load_extend = 1;
    end      
    opcode_lw   : begin
      is_load = 1;
      temp_dest = (regA_value + {{52{regB[11]}}, regB});
      sign_extend = 0;
      temp_datasize = DATA_32;
      next_load_extend = 1;
    end      
    opcode_lbu : begin
      is_load = 1;
      temp_dest = (regA_value + {{52{regB[11]}}, regB});
      sign_extend = 0;
      temp_datasize = DATA_8;
    end    
    opcode_lwu : begin
      is_load = 1;
      temp_dest = (regA_value + {{52{regB[11]}}, regB});
      sign_extend = 0;
      temp_datasize = DATA_32;
    end
    opcode_lhu  : begin
      is_load = 1;
      temp_dest = (regA_value + {{52{regB[11]}}, regB});
      sign_extend = 0;
      temp_datasize = DATA_16;
    end
    opcode_sb   : begin
      is_store = 1;
      off_dest12 = {regB[11:5], regDest};
      off_dest64 = {{52{off_dest12[11]}}, off_dest12};
      mem_dest   = regA_value + off_dest64;
      temp_dest  = $signed(regB_value[7:0]);
      sign_extend = 0;
      temp_datasize = DATA_8;
    end
    opcode_sh   : begin
      is_store = 1;
      off_dest12 = {regB[11:5], regDest};
      off_dest64 = {{52{off_dest12[11]}}, off_dest12};
      mem_dest   = regA_value + off_dest64;
      temp_dest  = $signed(regB_value[15:0]);
      temp_datasize = DATA_16;
    end
    opcode_sw   : begin
      is_store = 1;
      off_dest12 = {regB[11:5], regDest};
      off_dest64 = {{52{off_dest12[11]}}, off_dest12};
      mem_dest   = regA_value + off_dest64;
      temp_dest  = $signed(regB_value[31:0]);
      temp_datasize = DATA_32;
    end
    opcode_ld   : begin
      is_load = 1;
      temp_dest = regA_value + {{52{regB[11]}}, regB};
      sign_extend = 0;
      temp_datasize = DATA_64;
    end
    opcode_sd   : begin
      is_store = 1;
      off_dest12 = {regB[11:5], regDest};
      off_dest64 = {{52{off_dest12[11]}}, off_dest12};
      mem_dest   = regA_value + off_dest64;
      temp_dest  = regB_value;
      temp_datasize = DATA_64;
    end
    opcode_fence: begin
      temp_dest = 0;//regA_value + {{52{regB[11]}}, regB};
      sign_extend = 0;
    end
    opcode_fencei : begin
    end
    opcode_ecallebreak : begin
	case(regB[11:0])
		//ECALL - set a specific bit to mark this instruction
        	7'b000000000000: begin
          	is_ecall = 1;
        	end
		7'b000000000001: begin
		//EBREAK -- not needed
        	end
	endcase
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
      temp_dest = $signed(regA_value[31:0] + {{20{regB[11]}}, regB});
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
        temp_dest = 0;
        sign_extend = 0;
    end
  endcase
end
endmodule

