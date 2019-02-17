module decoder
(
 output [15:0] opcode, // opcode with instructions
 output [4:0] rs1, 
 output [4:0] rs2, 
 output [4:0] rd, //registers
 input [63:0] instr //input 32 bit instruction from PC
);
enum {
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
    opcodeUJ = 7'b1101111
    } OPS;
 
 always_comb begin
   
  case(OPS)
      opcodeR1: begin 
        opcode = "R";
        case(instr[14:12])
            3'b000: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("ADD ");
			 $display("rd,rs1,rs2");
		    end
		    7'b0100000: begin
			 $display("SUB ");
			 $display("rd,rs1,rs2");
		    end
		    7'b0000001: begin
			 $display("MUL ");
			 $display("rd,rs1,rs2");
		    end
		    default: $display("Unknown opcode\n");
		endcase
            end
            3'b001: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("SLL ");
			 $display("rd,rs1,rs2");
		    end
		    7'b0000001: begin
			 $display("MULH ");
			 $display("rd,rs1,rs2");
		    end
		    default: $display("Unknown opcode\n");
		endcase
            end
            3'b010: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("SLT ");
			 $display("rd,rs1,rs2");
		    end
		    7'b0000001: begin
			 $display("MULHSU ");
			 $display("rd,rs1,rs2");
		    end
                    default: $display("Unknown opcode\n");
		endcase
            end
            3'b011: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("SLTU ");
			 $display("rd,rs1,rs2");
		    end	
		    7'b0000001: begin
			 $display("MULHU ");
			 $display("rd,rs1,rs2");
		    end
                    default: $display("Unknown opcode\n");
		endcase
            end
            3'b100: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("XOR ");
			 $display("rd,rs1,rs2"); 
		    end
		    7'b0000001: begin
			 $display("DIV ");
			 $display("rd,rs1,rs2");
		    end
                    default: $display("Unknown opcode\n");
		endcase
            end
            3'b101: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("SRL ");
			 $display("rd,rs1,rs2");
		    end
		    7'b0100000: begin
			 $display("SRA ");
			 $display("rd,rs1,rs2");
		    end
		    7'b0000001: begin
			 $display("DIVU ");
			 $display("rd,rs1,rs2");
		    end
                    default: $display("Unknown opcode\n");
		endcase
            end
            3'b110: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("OR ");
			 $display("rd,rs1,rs2");
		    end
		    7'b0000001: begin
			 $display("REM ");
			 $display("rd,rs1,rs2");
		    end
                    default: $display("Unknown opcode\n");
		endcase
            end
            3'b111: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("AND ");
			 $display("rd,rs1,rs2");
		    end
		    7'b0000001: begin
			 $display("REMU ");
			 $display("rd,rs1,rs2");
		    end
                    default: $display("Unknown opcode\n");
		endcase
             end
             default: $display("Unknown opcode\n");
         endcase
     end
     opcodeR2: begin
        opcode = "R";
        case(instr[14:12])
            3'b000: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("ADDW ");
			 $display("rd,rs1,rs2");
		    end
		    7'b0100000: begin
			 $display("SUBW ");
			 $display("rd,rs1,rs2");
		    end
		    7'b0000001: begin
			 $display("MULW ");
			 $display("rd,rs1,rs2");
		    end
                    default: $display("Unknown opcode\n");
		endcase
            end
            3'b001: begin
                $display("SLLW ");
		$display("rd,rs1,rs2");
            end
            3'b100: begin
                $display("DIVW ");
		$display("rd,rs1,rs2");
            end
            3'b101: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("SRLW ");
			 $display("rd,rs1,rs2");
		    end
		    7'b0100000: begin
			 $display("SRAW ");
			 $display("rd,rs1,rs2");
		    end
	            7'b0000001: begin
			 $display("DIVUW ");
			 $display("rd,rs1,rs2");
	            end
                    default: $display("Unknown opcode\n");
		endcase
            end
            3'b110: begin
                $display("REMW ");
		$display("rd,rs1,rs2");
            end
            3'b111: begin
                $display("REMUW ");
		$display("rd,rs1,rs2");
            end
	    default: $display("Unknown opcode\n");
        endcase
    end


    opcodeI1: begin
        opcode = "I";
        $display("JALR ");
	$display("rd,rs1,offset");
    end
    opcodeI2: begin
        opcode = "I";
        case(instr[14:12])
            3'b000: begin
                $display("LB ");
		$display("rd,offset(rs1)");
            end
            3'b001: begin
                $display("LH ");
		$display("rd,offset(rs1)");
            end
            3'b010: begin
                $display("LW ");
		$display("rd,offset(rs1)");
            end
            3'b011: begin
                $display("LD ");
            end
            3'b100: begin
                $display("LBU ");
            end
            3'b101: begin
                $display("LHU ");
            end
            3'b110: begin
                $display("LWU ");
            end
            default: $display("Unknown opcode\n");
        endcase
    end
    opcodeI3: begin
        opcode = "I";
        case(instr[14:12])
            3'b000: begin
                $display("ADDI ");
            end
            3'b001: begin
                $display("SLLI");
            end
            3'b010: begin
                $display("SLTI");
            end
            3'b011: begin
                $display("SLTIU");
            end
            3'b100: begin
                $display("XORI");
            end
            3'b101: begin
                case(instr[30])
                    0'b1: begin
                        $display("SRLI");
                    end
                    1'b1: begin
                        $display("SRAI");
                    end
                endcase
            end
            3'b110: begin
                $display("ORI");
            end
            3'b111: begin
                $display("ANDI");
            end
        endcase
    end

    opcodeI4: begin
        opcode = "I";
        case(instr[14:12])
            3'b000: begin
                $display("ADDIW");
            end
            3'b001: begin
                $display("SLLIW");
            end
            3'b101: begin
                case(instr[30])
                    0'b1: begin
                        $display("SRLIW");
                    end
                    1'b1: begin
                        $display("SRAIW");
                    end
                endcase
            end
            default: $display("Unknown opcode\n");
        endcase
    end
    opcodeS: begin
        opcode = "S";
        case(instr[14:12])
            3'b000: begin
                $display("SB");
            end
            3'b001: begin
                $display("SH");
            end
            3'b010: begin
                $display("SW");
            end
            3'b011: begin
                $display("SD");
            end
            default: $display("Unknown opcode\n");
        endcase
    end

    opcodeSB: begin
        opcode = "SB";
        case(instr[14:12])
            3'b000: begin
                $display("BEQ");
            end
            3'b001: begin
                $display("BNE");
            end
            3'b100: begin
                $display("BLT");
            end
            3'b101: begin
                $display("BGE");
            end
            3'b110: begin
                $display("BLTU");
            end
            3'b111: begin
                $display("BGEU");
            end
            default: $display("Unknown opcode\n");
        endcase
    end

    opcodeU1: begin
        opcode = "U";
        $display("LUI");
    end

    opcodeU2: begin
        opcode = "U";
        $display("AUIPC");
    end

    opcodeUJ: begin
        opcode = "UJ";
        $display("JAL");
    end

   endcase
 end

endmodule

