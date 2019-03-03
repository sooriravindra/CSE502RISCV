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
   	opcode_addi		= 10'h013,
    	opcode_addiw		= 10'h01b,
     	opcode_addsubmulw	= 10'h03b,
    	opcode_andi		= 10'h393,
	opcode_slti		= 10'h113,
	opcode_sltiu		= 10'h193,
	opcode_xori		= 10'h213,
	opcode_ori		= 10'h313,
	opcode_addsubmul	= 10'h033,
	opcode_sllmulh		= 10'h0b3,
	opcode_sltmulhsu	= 10'h133,
	opcode_sltumulhu	= 10'h1b3,
	opcode_xordiv		= 10'h233,
	opcode_srlsradivu	= 10'h2b3,
	opcode_orrem		= 10'h333,
	opcode_andremu		= 10'h3b3,
	opcode_divw		= 10'h23b,
	opcode_srlsradivuw	= 10'h2bb,
	opcode_remw		= 10'h33b,
	opcode_remuw		= 10'h3bb,
	opcode_slli		= 10'h093,
	opcode_srlsrai		= 10'h293,
	opcode_srlsraiw		= 10'h29b,
	opcode_slliw		= 10'h09b,
	opcode_sllw		= 10'h0bb
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
                    temp_dest = register_file[regA][31:0] + register_file[regB[4:0]];
                    sign_extend = 1;
                end
                7'b0000001: begin
                    temp_dest = register_file[regA][31:0] * register_file[regB[4:0]];
                    sign_extend = 1;
                end
                7'b0100000: begin
                    temp_dest = register_file[regA][31:0] - register_file[regB[4:0]];
                    sign_extend = 1;
                end
            endcase
        end
        opcode_andi: begin
            temp_dest = register_file[regA][31:0] & {{52{regB[11]}}, regB};
            sign_extend = 0;
        end
        default: begin
        end
    endcase
end
endmodule

