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
               		 $display("ADD");
		    end
		    7'b0100000: begin
			 $display("SUB");
		    end
		    7'b0000001: begin
			 $display("MUL");
		    end
		endcase
            end
            3'b001: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("SLL");
		    end
		    7'b0000001: begin
			 $display("MULH");
		    end
		endcase
            end
            3'b010: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("SLT");
		    end
		    7'b0000001: begin
			 $display("MULHSU");
		    end
		endcase
            end
            3'b011: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("SLTU");
		    end	
		    7'b0000001: begin
			 $display("MULHU");
		    end
		endcase
            end
            3'b100: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("XOR");
		    end
		    7'b0000001: begin
			 $display("DIV");
		    end
		endcase
            end
            3'b101: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("SRL");
		    end
		    7'b0100000: begin
			 $display("SRA");
		    end
		    7'b0000001: begin
			 $display("DIVU");
		    end
		endcase
            end
            3'b110: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("OR");
		    end
		    7'b0000001: begin
			 $display("REM");
		    end
		endcase
            end
            3'b111: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("AND");
		    end
		    7'b0000001: begin
			 $display("REMU");
		    end
		endcase
             end
     end
     opcodeR2: begin
        opcode = "R";
        case(instr[14:12])
            3'b000: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("ADDW");
		    end
		    7'b0100000: begin
			 $display("SUBW");
		    end
		    7'b0000001: begin
			 $display("MULW");
		    end
		endcase
            end
            3'b001: begin
                $display("SLLW");
            end
            3'b100: begin
                $display("DIVW");
            end
            3'b101: begin
		case(instr[31:25])
		    7'b0000000: begin
               		 $display("SRLW");
		    end
		    7'b0100000: begin
			 $display("SRAW");
		    end
	            7'b0000001: begin
			 $display("DIVUW");
		endcase
            end
            3'b110: begin
                $display("REMW");
            end
            3'b111: begin
                $display("REMUW");
    end
    
    opcodeI1, opcodeI2, opcodeI3, opcodeI4: begin
        opcode = "I";
        case(instr[14:12])
            3'b000: begin
                $display("");
            end
            3'b001: begin
                $display("");
            end
            3'b010: begin
                $display("");
            end
            3'b011: begin
                $display("");
            end
            3'b100: begin
                $display("");
            end
            3'b101: begin
                $display("");
            end
            3'b110: begin
                $display("");
            end
            3'b111: begin
                $display("");
            end
    end

    opcodeS: begin
        opcode = "S";
        case(instr[14:12])
            3'b000: begin
                $display("");
            end
            3'b001: begin
                $display("");
            end
            3'b010: begin
                $display("");
            end
            3'b011: begin
                $display("");
            end
            3'b100: begin
                $display("");
            end
            3'b101: begin
                $display("");
            end
            3'b110: begin
                $display("");
            end
            3'b111: begin
                $display("");
            end
    end

    opcodeSB: begin
        opcode = "SB";
        case(instr[14:12])
            3'b000: begin
                $display("");
            end
            3'b001: begin
                $display("");
            end
            3'b010: begin
                $display("");
            end
            3'b011: begin
                $display("");
            end
            3'b100: begin
                $display("");
            end
            3'b101: begin
                $display("");
            end
            3'b110: begin
                $display("");
            end
            3'b111: begin
                $display("");
            end
    end

    opcodeU1, opcodeU2: begin
        opcode = "U";
        case(instr[14:12])
            3'b000: begin
                $display("");
            end
            3'b001: begin
                $display("");
            end
            3'b010: begin
                $display("");
            end
            3'b011: begin
                $display("");
            end
            3'b100: begin
                $display("");
            end
            3'b101: begin
                $display("");
            end
            3'b110: begin
                $display("");
            end
            3'b111: begin
                $display("");
            end
    end

    opcodeUJ: begin
        opcode = "UJ";
        case(instr[14:12])
            3'b000: begin
                $display("");
            end
            3'b001: begin
                $display("");
            end
            3'b010: begin
                $display("");
            end
            3'b011: begin
                $display("");
            end
            3'b100: begin
                $display("");
            end
            3'b101: begin
                $display("");
            end
            3'b110: begin
                $display("");
            end
            3'b111: begin
                $display("");
            end
    end

   endcase
 end

endmodule

