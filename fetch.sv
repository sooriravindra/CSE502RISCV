`include "instructions.sv"

module 
inc_pc(
	   input [63:0] pc_in,
           input [63:0] jmp_target, 
	   output[63:0] next_pc,
           input is_jmp,
           input alu_stall,
	   input sig_recvd,
	   input [63:0] pc_from_flush,
	   input fetch_flush
	  );
  logic is_updated;
  logic[63:0] update_pc;
  always_comb begin
    next_pc = pc_in;
    if (is_jmp) begin
        is_updated = 1;
        update_pc = jmp_target;
    end
    else if (fetch_flush) begin
        is_updated = 1;
        update_pc = pc_from_flush;
    end
    else if (sig_recvd) begin
        if (!is_updated) begin
            next_pc =  pc_in + 4;
        end
        else begin
            next_pc = update_pc;
        end
        is_updated = 0;
    end
    /*
    else if (alu_stall) begin
        is_updated = 1;
        update_pc = pc_in - 4;
    end
    */
  end
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
