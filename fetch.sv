`include "instructions.sv"

module 
inc_pc(
	   input [63:0] pc_in, 
	   output[63:0] next_pc
	  );
	assign next_pc = pc_in + 4;
endmodule

//module
//mux(
//	input [63:0] pc1, pc2,
//	input logic sel,
//	output[63:0] newpc_mux
//	);
//	assign newpc_mux = sel? pc1: pc2;
//endmodule

//module
//getnPC(
//	   input [63:0] npc_in,
//	   output[63:0] pcout
//	  );
//	initial
//	begin
//		pcout <= 0;
//	end
//	assign pcout = npc_in;
//endmodule

//module
//fetch_mod(
//			input exec_or_npc,
//			input [63:0] frm_exec,
//			output[63:0] if_id_instr, if_id_npc
//		   );
//	logic [63:0] npc_mux, pc, npc, data_out;
//	mux 	mux_1  (
//			   	    .pc1(npc), .pc2(frm_exec), .sel(exec_or_npc), .newpc_mux(npc_mux)
//			  	   );
//	inc_pc 	inc_pc1(
//				    .pc_in(pc), .next_pc(npc)
//				   );
//	getnPC newPCout(
//					.npc_in(npc_mux), .pcout(pc)
//				   );
//endmodule
