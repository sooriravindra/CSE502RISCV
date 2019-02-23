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

logic [31:0] temp_dest;

always_ff @(posedge clk) begin
    register_file[regDest] = temp_dest;
end

always_comb begin
    case (opcode)
        opcode_addi: begin
            $display("ADDI");
            temp_dest = register_file[regA] + {{52{regB[11]}}, regB} ;
        end
        opcode_addiw: begin
            $display("ADDIW");
            temp_dest = register_file[regA][31:0] + {{20{regB[11]}}, regB};
        end
        opcode_addsubmulw: begin
            case(regB[11:5])
                7'b0000000: begin
                    $display("ADDW");
                end
                7'b0000001: begin
                    $display("MULW");
                end
                7'b0100000: begin
                    $display("SUBW");
                end
            endcase
        end
        opcode_andi: $display("ANDI");
        default: begin
        end
    endcase
end
endmodule

