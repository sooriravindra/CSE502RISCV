
module decoder
(
  // 64-bit instruction data from the fetch
  input  [63:0] instruction_full
);

    logic [31:0] instruction = instruction_full[31:0];
    logic [6:0] opcode = instruction[6:0];
    logic [2:0] funct3 = instruction[14:12];

    always_comb begin
        case({funct3,opcode})
            10'b0000010011: $display("ADDI");
            default: $display("Unknown instruction");
        endcase
        $display("\n");
    end
endmodule
