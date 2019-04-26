`include "registers.sv"
module alu
(
    input [4:0] regA,
    input [11:0] regB,
    input [9:0] opcode,
    input [4:0] regDest,
    input clk
);

enum {
 	opcode_addi	   = 10'h013,
 	opcode_addiw	   = 10'h01b,
 	opcode_addsubmulw  = 10'h03b,
 	opcode_andi	   = 10'h393,
	opcode_slti	   = 10'h113,
	opcode_sltiu	   = 10'h193,
	opcode_xori	   = 10'h213,
	opcode_ori	   = 10'h313,
	opcode_addsubmul   = 10'h033,
	opcode_sllmulh	   = 10'h0b3,
	opcode_sltmulhsu   = 10'h133,
	opcode_sltumulhu   = 10'h1b3,
	opcode_xordiv	   = 10'h233,
	opcode_srlsradivu  = 10'h2b3,
	opcode_orrem	   = 10'h333,
	opcode_andremu	   = 10'h3b3,
	opcode_divw	   = 10'h23b,
	opcode_srlsradivuw = 10'h2bb,
	opcode_remw	   = 10'h33b,
	opcode_remuw       = 10'h3bb,
	opcode_slli	   = 10'h093,
	opcode_srlsrai	   = 10'h293,
	opcode_srlsraiw	   = 10'h29b,
	opcode_slliw	   = 10'h09b,
	opcode_sllw	   = 10'h0bb,
	opcode_lui	   = 10'bxxx0110111,
        opcode_jalauipc    = 10'bxxx0010111,
        opcode_jalr        = 10'h067,
        opcode_beq         = 10'h063,
        opcode_blt         = 10'h0e3,
        opcode_bge         = 10'h2e3,
        opcode_bltu        = 10'h363,
        opcode_bgeu        = 10'h3e3,
        opcode_lb          = 10'h003,
        opcode_lh          = 10'h083,
        opcode_lw          = 10'h103,
        opcode_lbulwu      = 10'h203,
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

logic [63:0] temp_dest;
logic sign_extend;

always_ff @(posedge clk) begin
  if (sign_extend) begin
    register_file[regDest] = {{32{temp_dest[31]}}, temp_dest[31:0]}; 
  end    
  else begin
    register_file[regDest] = temp_dest;
  end
end

always_comb begin
  case (opcode)
    opcode_addi: begin
      temp_dest = register_file[regA] + {{52{regB[11]}}, regB};
      sign_extend = 0;
    end
    opcode_addiw: begin
      temp_dest = register_file[regA][31:0] + {{20{regB[11]}}, regB};
      sign_extend = 1;
    end
    opcode_addsubmulw: begin
      case(regB[11:5])
        7'b0000000: begin
      	  temp_dest = register_file[regA][31:0] + register_file[regB[4:0]][31:0];
          	sign_extend = 1;
          end
          7'b0000001: begin
            temp_dest = register_file[regA][31:0] * register_file[regB[4:0]][31:0];
            sign_extend = 1;
          end
          7'b0100000: begin
            temp_dest = register_file[regA][31:0] - register_file[regB[4:0]][31:0];
            sign_extend = 1;
          end
        endcase
      end
      opcode_andi: begin
        temp_dest = register_file[regA] & {{52{regB[11]}}, regB};
        sign_extend = 0;
      end
      opcode_slti: begin
	if ($signed(register_file[regA]) < $signed({{52{regB[11]}}, regB})) begin
          temp_dest = 1;
      	end 
	else begin
          temp_dest = 0;
      	end
      	sign_extend = 0;	
      end
      opcode_sltiu: begin
	if (register_file[regA] < {{52{regB[11]}}, regB}) begin
	  temp_dest = 1;
	end 
        else begin
	  temp_dest = 0;
	end
	sign_extend = 0;
	end
	opcode_xori: begin
	  temp_dest = register_file[regA] ^ {{52{regB[11]}}, regB};
	  sign_extend = 0;
	end
	opcode_ori: begin
	  temp_dest = register_file[regA] | {{52{regB[11]}}, regB};
	  sign_extend = 0;
	end
	opcode_addsubmul: begin
	  case(regB[11:5])
	    7'b0000000: begin
	      temp_dest = register_file[regA] + register_file[regB[4:0]];
	      sign_extend = 0;
	    end
	    7'b0000001: begin
	      temp_dest = register_file[regA] * register_file[regB[4:0]];
	      sign_extend = 0;
	    end
	    7'b0100000: begin
	      temp_dest = register_file[regA] - register_file[regB[4:0]];
	      sign_extend = 0;
	    end
	  endcase
	end
	opcode_sllmulh: begin
	  case(regB[11:5])
	    7'b0000000: begin
	      temp_dest = register_file[regA] << register_file[regB[4:0]];
	    end
	    7'b0000001: begin
	      logic [63:0] product = $signed(register_file[regA]) * $signed(register_file[regB[4:0]]); 
	      temp_dest = product[63:32];
	    end
	  endcase
	  sign_extend = 0;
	end
	opcode_sltmulhsu: begin
	  case(regB[11:5])
	    7'b0000000: begin
              if ($signed(register_file[regA]) < $signed(register_file[regB[4:0]])) begin
  	        temp_dest = 1;
     	      end 
	      else begin
        	temp_dest = 0;
              end
            end
            7'b0000001: begin
              logic [63:0] product = $signed(register_file[regA]) * register_file[regB[4:0]];
              temp_dest = product[63:32];
            end
          endcase
	  sign_extend = 0;
      	end
      	opcode_sltumulhu: begin
      	  case(regB[11:5])
            7'b0000000: begin
              if (register_file[regA] < register_file[regB[4:0]]) begin
                temp_dest = 1;
              end 
      	      else begin
                temp_dest = 0;
              end
            end
            7'b0000001: begin
              logic [63:0] product = register_file[regA] * register_file[regB[4:0]];
              temp_dest = product[63:32];
            end
          endcase
	    sign_extend = 0;
	end
	opcode_xordiv: begin 
	  case(regB[11:5])
	    7'b0000000: begin
	      temp_dest = register_file[regA] ^ register_file[regB[4:0]];
	      sign_extend = 0;
	    end
	    7'b0000001: begin
	      temp_dest = $signed(register_file[regA]) / $signed(register_file[regB[4:0]]);
	      sign_extend = 0;
	    end
          endcase
	end
	opcode_srlsradivu: begin
	  case(regB[11:5])
            7'b0000000: begin
              temp_dest = register_file[regA] >> register_file[regB[4:0]];
              sign_extend = 0;
            end
            7'b0100000: begin
              temp_dest = $signed(register_file[regA]) >> register_file[regB[4:0]];
              sign_extend = 0;
            end
            7'b0000001: begin
              temp_dest = register_file[regA] / register_file[regB[4:0]];
              sign_extend = 0;
            end
          endcase
	end
	opcode_orrem: begin
	  case(regB[11:5])
            7'b0000000: begin
              temp_dest = register_file[regA] | register_file[regB[4:0]];
              sign_extend = 0;
            end
            7'b0000001: begin
	      temp_dest =$signed(register_file[regA]) % $signed(register_file[regB[4:0]]);
	      sign_extend = 0;
            end
          endcase
	end
	opcode_andremu: begin
	  case(regB[11:5])
            7'b0000000: begin
              temp_dest = register_file[regA] & register_file[regB[4:0]];
              sign_extend = 0;
            end
            7'b0000001: begin
              temp_dest = register_file[regA] % register_file[regB[4:0]];
              sign_extend = 0;
            end
          endcase
	end
	opcode_divw: begin
	  temp_dest = $signed(register_file[regA][31:0]) / $signed(register_file[regB[4:0]][31:0]);
	  sign_extend = 1; 
	end
	opcode_srlsradivuw: begin
	  case(regB[11:5])
            7'b0000000: begin
              temp_dest = register_file[regA][31:0] >> register_file[regB[4:0]][31:0];
              sign_extend = 1;
            end
            7'b0100000: begin
              temp_dest = $signed(register_file[regA][31:0]) >> register_file[regB[4:0]][31:0];
              sign_extend = 1;
            end
            7'b0000001: begin
              temp_dest = register_file[regA][31:0] / register_file[regB[4:0]][31:0];
              sign_extend = 1;
            end
          endcase
	end
	opcode_remw: begin
	  temp_dest = $signed(register_file[regA][31:0]) % $signed(register_file[regB[4:0]][31:0]);
          sign_extend = 1;
	end
	opcode_remuw: begin
          temp_dest = register_file[regA][31:0] % register_file[regB[4:0]][31:0];
          sign_extend = 1;
	end
	opcode_slli: begin
	  temp_dest = register_file[regA] << regB[4:0];
	  sign_extend = 0;
	end
	opcode_srlsrai: begin
	  case(regB[11:5])
	    7'b0000000: begin
	      temp_dest = register_file[regA] >> regB[4:0];
              sign_extend = 0;                 
            end
            7'b0100000: begin
	      temp_dest = $signed(register_file[regA]) >> regB[4:0];
  	      sign_extend = 0;
            end
          endcase
	end
	opcode_srlsraiw: begin
          case(regB[11:5]) 
            7'b0000000: begin
	      temp_dest = register_file[regA][31:0] >> regB[5:0]; // 6 bits immediate value
	      sign_extend = 1;
            end
            7'b0100000: begin
              temp_dest = $signed(register_file[regA][31:0]) >> regB[5:0]; // 6 bits immediate value
              sign_extend = 1;
            end
          endcase
	end
	opcode_slliw: begin
	  temp_dest = register_file[regA][31:0] << regB[5:0]; //6 bits immediate value
	  sign_extend = 1; 
	end
	opcode_sllw:begin
	  temp_dest = register_file[regA][31:0] << register_file[regB[4:0]][31:0];
          sign_extend = 1;
	end
        default: begin
        end
      endcase
    end
endmodule

