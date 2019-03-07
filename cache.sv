`include "states.sv"

module 
i_cache(
		input  logic[63:0] i_pc,
		input  logic clk,
		input  logic reset,
		input  logic req_recvd,
		output logic[63:0] o_pc,
		output logic flag_rdy
	   );
	logic 		c_hit, c_miss, pass; 
	logic 		bus_respack, update_done;
	logic [511:0] value;
	always_comb begin
		case(c_state)
			INITIAL		: begin
				o_pc 	 	= 0;
				flag_rdy 	= 0;
				c_hit	 	= 0;
				c_miss	 	= 0;
				pass	 	= 0;
				bus_respack = 0;
				update_done = 0;
				value 		= 0;
			end
			BUSY   		: begin
				
			end
			FOUND  		: begin
			end
			REQ_BUS		: begin
			end
			UPDATE_CACHE: begin
			end
		endcase
	end
	always_ff @(posedge clk) begin
		if (reset) begin
			
		end
	end
	always_comb begin
		case(c_state)
			INITIAL		: begin
			end
			BUSY   		: begin
			end
			FOUND  		: begin
			end
			REQ_BUS		: begin
			end
			UPDATE_CACHE: begin
			end
		endcase	
	end
		
endmodule
