module decoder
(
// output [15:0] opcode, // opcode with instructions
// output [4:0] rs1, 
// output [4:0] rs2, 
// output [4:0] rd, //registers
 input [31:0] instr, //input 32 bit instruction from PC
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
               		 $display("ADD rd, rs1, rs2");
		    end
		    7'b0100000: begin
			 $display("SUB rd, rs1, rs2");
		    end
		    7'b0000001: begin
			 $display("MUL rd, rs1, rs2");
		    end
		    default: $display("Unknown opcode\n");
		endcase
            end
            3'b001: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("SLL rd, rs1, rs2");
		    end
		    7'b0000001: begin
			 $display("MULH rd, rs1, rs2");
		    end
		    default: $display("Unknown opcode\n");
		endcase
            end
            3'b010: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("SLT rd, rs1, rs2");
		    end
		    7'b0000001: begin
			 $display("MULHSU rd, rs1, rs2");
		    end
                    default: $display("Unknown opcode\n");
		endcase
            end
            3'b011: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("SLTU rd, rs1, rs2");
		    end	
		    7'b0000001: begin
			 $display("MULHU rd, rs1, rs2");
		    end
                    default: $display("Unknown opcode\n");
		endcase
            end
            3'b100: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("XOR rd, rs1, rs2"); 
		    end
		    7'b0000001: begin
			 $display("DIV rd, rs1, rs2");
		    end
                    default: $display("Unknown opcode\n");
		endcase
            end
            3'b101: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("SRL rd, rs1, rs2");
		    end
		    7'b0100000: begin
			 $display("SRA rd, rs1, rs2");
		    end
		    7'b0000001: begin
			 $display("DIVU rd, rs1, rs2");
		    end
                    default: $display("Unknown opcode\n");
		endcase
            end
            3'b110: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("OR rd, rs1, rs2");
		    end
		    7'b0000001: begin
			 $display("REM rd, rs1, rs2");
		    end
                    default: $display("Unknown opcode\n");
		endcase
            end
            3'b111: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("AND rd, rs1, rs2");
		    end
		    7'b0000001: begin
			 $display("REMU rd, rs1, rs2");
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
               		 $display("ADDW rd, rs1, rs2");
		    end
		    7'b0100000: begin
			 $display("SUBW rd, rs1, rs2");
		    end
		    7'b0000001: begin
			 $display("MULW rd, rs1, rs2");
		    end
                    default: $display("Unknown opcode\n");
		endcase
            end
            3'b001: begin
                $display("SLLW rd, rs1, rs2");
            end
            3'b100: begin
                $display("DIVW rd, rs1, rs2");
            end
            3'b101: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("SRLW rd, rs1, rs2");
		    end
		    7'b0100000: begin
			 $display("SRAW rd, rs1, rs2");
		    end
	            7'b0000001: begin
			 $display("DIVUW rd, rs1, rs2");
	            end
                    default: $display("Unknown opcode\n");
		endcase
            end
            3'b110: begin
                $display("REMW rd, rs1, rs2");
            end
            3'b111: begin
                $display("REMUW rd, rs1, rs2");
            end
	    default: $display("Unknown opcode\n");
        endcase
    end


    opcodeI1: begin
        // opcode = "I";
        $display("JALR rd, rs1, 0x%h", $signed(instr[31:20]));
        end
    opcodeI2: begin
        //opcode = "I";
        case(instr[14:12])
            3'b000: begin
                $display("LB rd, %d(rs1)", $signed(instr[31:20]));
            end
            3'b001: begin
                $display("LH rd, %d(rs1)", $signed(instr[31:20]));
            end
            3'b010: begin
                $display("LW rd, %d(rs1)", $signed(instr[31:20]));
            end
            3'b011: begin
                $display("LD rd, %d(rs1)", $signed(instr[31:20]));
            end
            3'b100: begin
                $display("LBU rd, %d(rs1)", $signed(instr[31:20]));
            end
            3'b101: begin
                $display("LHU rd, %d(rs1)", $signed(instr[31:20]));
            end
            3'b110: begin
                $display("LWU rd, %d(rs1)", $signed(instr[31:20]));
            end
            default: $display("Unknown opcode\n");
        endcase
    end
    opcodeI3: begin
        //opcode = "I";
        case(instr[14:12])
            3'b000: begin
                $display("ADDI rd, rs1, %d", $signed(instr[31:20]));
            end
	    //shift immediate instructions should only use lowest 5 bits
	    //of the immediate value
            3'b001: begin
                $display("SLLI rd, rs1, %d", $signed(instr[24:20]));
            end
            3'b010: begin
                $display("SLTI rd, rs1, %d", $signed(instr[31:20]));
            end
            3'b011: begin
                $display("SLTIU rd, rs1, %d", $signed(instr[31:20]));
            end
            3'b100: begin
                $display("XORI rd, rs1, %d", $signed(instr[31:20]));
            end
            3'b101: begin
                case(instr[30])
	  	    //shift immediate instructions should only use lowest 5 bits
                    0'b1: begin
                        $display("SRLI rd, rs1, %d", $signed(instr[24:20]));
                    end
                    1'b1: begin
                        $display("SRAI rd, rs1, %d", $signed(instr[24:20]));
                    end
                endcase
            end
            3'b110: begin
                $display("ORI rd, rs1, %d", $signed(instr[31:20]));
            end
            3'b111: begin
                $display("ANDI rd, rs1, %d", $signed(instr[31:20]));
            end
        endcase
    end

    opcodeI4: begin
        //opcode = "I";
        case(instr[14:12])
            3'b000: begin
                $display("ADDIW rd, rs1, %d", $signed(instr[31:20]));
            end
	    //shift instructions use lowest 5 bits for immediate
            3'b001: begin
                $display("SLLIW rd,rs1, %d", $signed(instr[24:20]));
            end
            3'b101: begin
                case(instr[30])
		    //shift instructions use lowest 5 bits for immediate
                    0'b1: begin
                        $display("SRLIW rd,rs1, %d", $signed(instr[24:20]));
                    end
                    1'b1: begin
                        $display("SRAIW rd,rs1, %d", $signed(instr[24:20]));
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
                $display("SB rs2, %d(rs1)", $signed({instr[31:25],instr[11:7]}));
            end
            3'b001: begin 
		$display("SH rs2, %d(rs1)", $signed({instr[31:25],instr[11:7]}));
            end
            3'b010: begin 
		$display("SW rs2, %d(rs1)", $signed({instr[31:25],instr[11:7]}));
            end
            3'b011: begin 
		$display("SD rs2, %d(rs1)", $signed({instr[31:25],instr[11:7]}));
            end
            default: $display("Unknown opcode\n");
        endcase
    end

    opcodeSB: begin
        //opcode = "SB";
        case(instr[14:12])
            3'b000: begin
                $display("BEQ rs1, rs2, 0x%h", $signed({instr[31:25],instr[11:7]}));
            end
            3'b001: begin
                $display("BNE rs1, rs2, 0x%h", $signed({instr[31:25],instr[11:7]}));
            end
            3'b100: begin
                $display("BLT rs1, rs2, 0x%h", $signed({instr[31:25],instr[11:7]}));
            end
            3'b101: begin
                $display("BGE rs1, rs2, 0x%h", $signed({instr[31:25],instr[11:7]}));
            end
            3'b110: begin
                $display("BLTU rs1, rs2, 0x%h", $signed({instr[31:25],instr[11:7]}));
            end
            3'b111: begin
                $display("BGEU rs1, rs2, 0x%h", $signed({instr[31:25],instr[11:7]}));
            end
            default: $display("Unknown opcode\n");
        endcase
    end

    opcodeU1: begin
        //opcode = "U";
        $display("LUI rd, 0x%h", $signed(instr[31:12]));
    end

    opcodeU2: begin
        //opcode = "U";
        $display("AUIPC rd, 0x%h", $signed(instr[31:12]));
    end

    opcodeUJ: begin
        //opcode = "UJ";
        $display("JAL rd, 0x%h", $signed(instr[31:12]));
    end

   endcase
 end

endmodule
