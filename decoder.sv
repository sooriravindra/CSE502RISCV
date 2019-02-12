module decoder();

 output opcode; // opcode with instructions
 output [4:0] rs1, rs2, rd; //registers
 input [32:0] instr; //input 32 bit instruction from PC
 enum {opcodeR=6'b0110011, opcodeI=6'b0010011, opcodeS=6'b0100011, opcodeSB=6'b1100011, opcodeU=6'b0110111, opcodeUJ=6'b1101111} OPS;
 
 always_comb begin
   
  case(OPS)
   opcodeR: 
	opcode = "R";
	if (input[14:12] == 000) begin
		
	
	end else if (input[14:12] == 001) begin


	end else if (input[14:12] == 010) begin


	end else if (input[14:12] == 011) begin


	end else if (input[14:12] == 100) begin


	end else if (input[14:12] == 101) begin


	end else if (input[14:12] == 110) begin


	end else if (input[14:12] == 111) begin


	end


   opcodeI: 
	opcode = "I";
	if (input[14:12] == 000) begin


        end else if (input[14:12] == 001) begin


        end else if (input[14:12] == 010) begin


        end else if (input[14:12] == 011) begin


        end else if (input[14:12] == 100) begin


        end else if (input[14:12] == 101) begin


        end else if (input[14:12] == 110) begin


        end else if (input[14:12] == 111) begin


        end

   opcodeS: 
	opcode = "S";
	if (input[14:12] == 000) begin


        end else if (input[14:12] == 001) begin


        end else if (input[14:12] == 010) begin


        end else if (input[14:12] == 011) begin


        end else if (input[14:12] == 100) begin


        end else if (input[14:12] == 101) begin


        end else if (input[14:12] == 110) begin


        end else if (input[14:12] == 111) begin


        end

   opcodeSB: 
	opcode = "SB";
	if (input[14:12] == 000) begin


        end else if (input[14:12] == 001) begin


        end else if (input[14:12] == 010) begin


        end else if (input[14:12] == 011) begin


        end else if (input[14:12] == 100) begin


        end else if (input[14:12] == 101) begin


        end else if (input[14:12] == 110) begin


        end else if (input[14:12] == 111) begin


        end

   opcodeU: 
	opcode = "U";
	if (input[14:12] == 000) begin


        end else if (input[14:12] == 001) begin


        end else if (input[14:12] == 010) begin


        end else if (input[14:12] == 011) begin


        end else if (input[14:12] == 100) begin


        end else if (input[14:12] == 101) begin


        end else if (input[14:12] == 110) begin


        end else if (input[14:12] == 111) begin


        end

   opcodeUJ: 
	opcode = "UJ";
	if (input[14:12] == 000) begin


        end else if (input[14:12] == 001) begin


        end else if (input[14:12] == 010) begin


        end else if (input[14:12] == 011) begin


        end else if (input[14:12] == 100) begin


        end else if (input[14:12] == 101) begin


        end else if (input[14:12] == 110) begin


        end else if (input[14:12] == 111) begin


        end

   endcase
 end

endmodule

