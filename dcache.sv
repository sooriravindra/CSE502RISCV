`include "states.sv"

module 
dcache
(
		 	 input 											clk,
			 input 											wr_en,
			 input 				[WIDTH-1:0] 	data_in, 
			 input				[LOGSIZE-1:0] r_addr, 
			 input				[LOGSIZE-1:0] w_addr, 
			 input											rst,
			 output logic [WIDTH-1:0] 	data_out,
			 output logic [LOGSIZE-1:0]	addr_out
);
parameter  WIDTH=16, LOGSIZE=8;
localparam SIZE=2**LOGSIZE;
logic [WIDTH-1:0] mem[SIZE-1:0];

  logic                  c_hit, pass, on_req, bus_respack, update_done;
  logic [NUMLINES - 1:0] value;
  logic [WIDTH - 1:0]    cachedata [NUMLINES - 1:0];
  logic [TAGWIDTH - 1:0] cachetag  [NUMLINES - 1:0];
  logic                  cachestate[NUMLINES - 1:0];
  logic [INSTSIZE - 1:0] curr_inst;

always_comb begin
	case(c_state) begin
		INIT				: begin
			
		end
		BUSY				:	begin
			
		end
		FOUND				: begin
		end
		REQ_BUS			: begin
		end
		UPDATE_CACHE: begin
			cachedata[index] = data_in;
			
		end
	endcase
end

always_ff @(posedge clk) begin
	if (rst == 1) begin
		data_out <= 0;
	end
	else begin
		data_out <= mem[r_addr];

		if (wr_en) begin
			mem[w_addr] <= data_in;
		end
	end
end

always_comb begin
	FOUND					: begin
		if (wr_en) begin
			addr_out = w_addr;
		end
		else begin
			addr_out = r_addr;
		end
	end
end

endmodule
