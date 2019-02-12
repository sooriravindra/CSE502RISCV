module decoder
(
 output [15:0] opcode, // opcode with instructions
 output [4:0] rs1, 
 output [4:0] rs2, 
 output [4:0] rd, //registers
 input [63:0] instr //input 32 bit instruction from PC
);
 enum {opcodeR=7'b0110011, opcodeI=7'b0010011, opcodeS=7'b0100011, opcodeSB=7'b1100011, opcodeU=7'b0110111, opcodeUJ=7'b1101111} OPS;
 
 always_comb begin
   
  case(OPS)
      opcodeR: begin 
	opcode = "R";
	if (instr[14:12] == 3'b000) begin
	    $display("");	
	
	end else if (instr[14:12] == 3'b001) begin
	    $display("");	


	end else if (instr[14:12] == 3'b010) begin
	    $display("");	


	end else if (instr[14:12] == 3'b011) begin
	    $display("");	


	end else if (instr[14:12] == 3'b100) begin
	    $display("");	


	end else if (instr[14:12] == 3'b101) begin
	    $display("");	


	end else if (instr[14:12] == 3'b110) begin
	    $display("");	


	end else if (instr[14:12] == 3'b111) begin
	    $display("");	


	end
    end


    opcodeI: begin
	opcode = "I";
	if (instr[14:12] == 3'b000) begin
	    $display("");	


        end else if (instr[14:12] == 3'b001) begin
	    $display("");	


        end else if (instr[14:12] == 3'b010) begin
	    $display("");	


        end else if (instr[14:12] == 3'b011) begin
	    $display("");	


        end else if (instr[14:12] == 3'b100) begin
	    $display("");	


        end else if (instr[14:12] == 3'b101) begin
	    $display("");	


        end else if (instr[14:12] == 3'b110) begin
	    $display("");	


        end else if (instr[14:12] == 3'b111) begin
	    $display("");	


        end
    end

    opcodeS: begin
	opcode = "S";
	if (instr[14:12] == 3'b000) begin
	    $display("");	


        end else if (instr[14:12] == 3'b001) begin
	    $display("");	


        end else if (instr[14:12] == 3'b010) begin
	    $display("");	


        end else if (instr[14:12] == 3'b011) begin
	    $display("");	


        end else if (instr[14:12] == 3'b100) begin
	    $display("");	


        end else if (instr[14:12] == 3'b101) begin
	    $display("");	


        end else if (instr[14:12] == 3'b110) begin
	    $display("");	


        end else if (instr[14:12] == 3'b111) begin
	    $display("");	


        end
    end

    opcodeSB: begin
	opcode = "SB";
	if (instr[14:12] == 3'b000) begin
	    $display("");	


        end else if (instr[14:12] == 3'b001) begin
	    $display("");	


        end else if (instr[14:12] == 3'b010) begin
	    $display("");	


        end else if (instr[14:12] == 3'b011) begin
	    $display("");	


        end else if (instr[14:12] == 3'b100) begin
	    $display("");	


        end else if (instr[14:12] == 3'b101) begin
	    $display("");	


        end else if (instr[14:12] == 3'b110) begin
	    $display("");	


        end else if (instr[14:12] == 3'b111) begin
	    $display("");	


        end
    end

    opcodeU: begin
	opcode = "U";
	if (instr[14:12] == 3'b000) begin
	    $display("");	


        end else if (instr[14:12] == 3'b001) begin
	    $display("");	


        end else if (instr[14:12] == 3'b010) begin
	    $display("");	


        end else if (instr[14:12] == 3'b011) begin
	    $display("");	


        end else if (instr[14:12] == 3'b100) begin
	    $display("");	


        end else if (instr[14:12] == 3'b101) begin
	    $display("");	


        end else if (instr[14:12] == 3'b110) begin
	    $display("");	


        end else if (instr[14:12] == 3'b111) begin
	    $display("");	


        end
    end

    opcodeUJ: begin
	opcode = "UJ";
	if (instr[14:12] == 3'b000) begin
	    $display("");	


        end else if (instr[14:12] == 3'b001) begin
	    $display("");	


        end else if (instr[14:12] == 3'b010) begin
	    $display("");	


        end else if (instr[14:12] == 3'b011) begin
	    $display("");	


        end else if (instr[14:12] == 3'b100) begin
	    $display("");	


        end else if (instr[14:12] == 3'b101) begin
	    $display("");	


        end else if (instr[14:12] == 3'b110) begin
	    $display("");	


        end else if (instr[14:12] == 3'b111) begin
	    $display("");	


        end
    end

   endcase
 end

endmodule

