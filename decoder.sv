module decoder
(
// output [15:0] opcode, // opcode with instructions
// output [4:0] rs1, 
// output [4:0] rs2, 
// output [4:0] rd, //registers
 input [63:0] instr, //input 32 bit instruction from PC
 input clk
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
 
 assign OPS = instr[6:0];
 always_ff @(posedge clk) begin
   
  case(OPS)
      opcodeR1: begin 
        //opcode = "R";
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
        //opcode = "R";
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
        // opcode = "I";
        $display("JALR ");
	$display("rd,rs1,offset");
        end
    opcodeI2: begin
        //opcode = "I";
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
		$display("rd,offset(rs1)");
            end
            3'b100: begin
                $display("LBU ");
		$display("rd,offset(rs1)");
            end
            3'b101: begin
                $display("LHU ");
		$display("rd,offset(rs1)");
            end
            3'b110: begin
                $display("LWU ");
		$display("rd,offset(rs1)");
            end
            default: $display("Unknown opcode\n");
        endcase
    end
    opcodeI3: begin
        //opcode = "I";
        case(instr[14:12])
            3'b000: begin
                $display("ADDI ");
		$display("rd,rs1,imm");
            end
            3'b001: begin
                $display("SLLI ");
		$display("rd,rs1,imm");
            end
            3'b010: begin
                $display("SLTI ");
		$display("rd,rs1,imm");
            end
            3'b011: begin
                $display("SLTIU ");
		$display("rd,rs1,imm");
            end
            3'b100: begin
                $display("XORI ");
		$display("rd,rs1,imm");
            end
            3'b101: begin
                case(instr[30])
                    0'b1: begin
                        $display("SRLI ");
			$display("rd,rs1,imm");
                    end
                    1'b1: begin
                        $display("SRAI ");
			$display("rd,rs1,imm");
                    end
                endcase
            end
            3'b110: begin
                $display("ORI ");
		$display("rd,rs1,imm");
            end
            3'b111: begin
                $display("ANDI ");
		$display("rd,rs1,imm");
            end
        endcase
    end

    opcodeI4: begin
        //opcode = "I";
        case(instr[14:12])
            3'b000: begin
                $display("ADDIW ");
		$display("rd,rs1,imm");
            end
            3'b001: begin
                $display("SLLIW ");
		$display("rd,rs1,imm");
            end
            3'b101: begin
                case(instr[30])
                    0'b1: begin
                        $display("SRLIW ");
			$display("rd,rs1,imm");
                    end
                    1'b1: begin
                        $display("SRAIW ");
			$display("rd,rs1,imm");
                    end
                endcase
            end
            default: $display("Unknown opcode\n");
        endcase
    end
    opcodeS: begin
        //opcode = "S";
        case(instr[14:12])
            3'b000: begin
                $display("SB ");
		$display("rs2,offset(rs1)");
            end
            3'b001: begin
                $display("SH ");
		$display("rs2,offset(rs1)");
            end
            3'b010: begin
                $display("SW ");
		$display("rs2,offset(rs1)");
            end
            3'b011: begin
                $display("SD ");
		$display("rs2,offset(rs1)");
            end
            default: $display("Unknown opcode\n");
        endcase
    end

    opcodeSB: begin
        //opcode = "SB";
        case(instr[14:12])
            3'b000: begin
                $display("BEQ ");
		$display("rs1,rs2,offset");
            end
            3'b001: begin
                $display("BNE ");
		$display("rs1,rs2,offset");
            end
            3'b100: begin
                $display("BLT ");
		$display("rs1,rs2,offset");
            end
            3'b101: begin
                $display("BGE ");
		$display("rs1,rs2,offset");
            end
            3'b110: begin
                $display("BLTU ");
		$display("rs1,rs2,offset");
            end
            3'b111: begin
                $display("BGEU ");
		$display("rs1,rs2,offset");
            end
            default: $display("Unknown opcode\n");
        endcase
    end

    opcodeU1: begin
        //opcode = "U";
        $display("LUI");
	$display("rd,imm");
    end

    opcodeU2: begin
        //opcode = "U";
        $display("AUIPC");
	$display("rd,offset");
    end

    opcodeUJ: begin
        //opcode = "UJ";
        $display("JAL");
	$display("rd,offset");
    end

   endcase
 end

endmodule

