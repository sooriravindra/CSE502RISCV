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
    opcode_addi         = 10'h013,
    opcode_addiw        = 10'h01b,
    opcode_addsubmulw   = 10'h03b,
    opcode_andi         = 10'h393
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

