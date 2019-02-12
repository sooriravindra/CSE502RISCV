module decoder
(
 output [15:0] opcode, // opcode with instructions
 output [4:0] rs1, 
 output [4:0] rs2, 
 output [4:0] rd, //registers
 input [32:0] instr //input 32 bit instruction from PC
);
 enum {opcodeR=7'b0110011, opcodeI=7'b0010011, opcodeS=7'b0100011, opcodeSB=7'b1100011, opcodeU=7'b0110111, opcodeUJ=7'b1101111} OPS;
 
 always_comb begin
   
  case(OPS)
      opcodeR: begin 
	opcode = "R";
	if (instr[14:12] == 3'b000) begin
		
	
	end else if (instr[14:12] == 3'b001) begin


	end else if (instr[14:12] == 3'b010) begin


	end else if (instr[14:12] == 3'b011) begin


	end else if (instr[14:12] == 3'b100) begin


	end else if (instr[14:12] == 3'b101) begin


	end else if (instr[14:12] == 3'b110) begin


	end else if (instr[14:12] == 3'b111) begin


	end
    end


    opcodeI: begin
	opcode = "I";
	if (instr[14:12] == 3'b000) begin


        end else if (instr[14:12] == 3'b001) begin


        end else if (instr[14:12] == 3'b010) begin


        end else if (instr[14:12] == 3'b011) begin


        end else if (instr[14:12] == 3'b100) begin


        end else if (instr[14:12] == 3'b101) begin


        end else if (instr[14:12] == 3'b110) begin


        end else if (instr[14:12] == 3'b111) begin


        end
    end

    opcodeS: begin
	opcode = "S";
	if (instr[14:12] == 3'b000) begin


        end else if (instr[14:12] == 3'b001) begin


        end else if (instr[14:12] == 3'b010) begin


        end else if (instr[14:12] == 3'b011) begin


        end else if (instr[14:12] == 3'b100) begin


        end else if (instr[14:12] == 3'b101) begin


        end else if (instr[14:12] == 3'b110) begin


        end else if (instr[14:12] == 3'b111) begin


        end
    end

    opcodeSB: begin
	opcode = "SB";
	if (instr[14:12] == 3'b000) begin


        end else if (instr[14:12] == 3'b001) begin


        end else if (instr[14:12] == 3'b010) begin


        end else if (instr[14:12] == 3'b011) begin


        end else if (instr[14:12] == 3'b100) begin


        end else if (instr[14:12] == 3'b101) begin


        end else if (instr[14:12] == 3'b110) begin


        end else if (instr[14:12] == 3'b111) begin


        end
    end

    opcodeU: begin
	opcode = "U";
	if (instr[14:12] == 3'b000) begin


        end else if (instr[14:12] == 3'b001) begin


        end else if (instr[14:12] == 3'b010) begin


        end else if (instr[14:12] == 3'b011) begin


        end else if (instr[14:12] == 3'b100) begin


        end else if (instr[14:12] == 3'b101) begin


        end else if (instr[14:12] == 3'b110) begin


        end else if (instr[14:12] == 3'b111) begin


        end
    end

    opcodeUJ: begin
	opcode = "UJ";
	if (instr[14:12] == 3'b000) begin


        end else if (instr[14:12] == 3'b001) begin


        end else if (instr[14:12] == 3'b010) begin


        end else if (instr[14:12] == 3'b011) begin


        end else if (instr[14:12] == 3'b100) begin


        end else if (instr[14:12] == 3'b101) begin


        end else if (instr[14:12] == 3'b110) begin


        end else if (instr[14:12] == 3'b111) begin


        end
    end

   endcase
 end

endmodule

