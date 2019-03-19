`include "states.sv"

module 
i_cache
#(
  WIDTH    = 64,
  NUMLINES = 512,
  TAGWIDTH = 48,
  IDXWIDTH = 10,
  OFFWIDTH = 6,
  IDXBITS  = 15:6,
  TAGBITS  = 63:16,
  INSTSIZE = 32
)
(
    input  logic[WIDTH - 1:0]     i_pc,
    input  logic                  clk,
    input  logic                  reset,
    input  logic                  req_recvd,
    input  logic[INSTSIZE - 1:0] 	inp_instr,
    output logic[INSTSIZE - 1:0]  out_instr,
//  output logic[WIDTH - 1:0]     o_pc,
    output logic                  flag_rdy
);
  logic                  c_hit, pass, on_req, bus_respack, update_done;
  logic [NUMLINES - 1:0] value;
  logic [WIDTH - 1:0]    cachedata [NUMLINES - 1:0];
  logic [TAGWIDTH - 1:0] cachetag	 [NUMLINES - 1:0];
  logic                  cachestate[NUMLINES - 1:0];
  logic [INSTSIZE - 1:0] curr_inst;
  always_comb begin
    case(c_state)
      INIT        : begin
        o_pc        = 0;
        c_hit       = 0;
        pass        = 0;
        bus_respack = 0;
        update_done = 0;
        value       = 0;
      end
      BUSY         : begin
        if ((cachestate[i_pc[IDXBITS]] == 1) & (cachetag[i_pc[IDXBITS] == i_pc[TAGBITS])) begin
          c_hit = 1;
        end
        else begin
          c_hit = 0;
        end
      end
      FOUND        : begin
        if (pass) begin
          // Now that the value is found
          curr_instr = inp_instr;
        end
        else begin
          curr_instr = 64'hAAAAAAAAAAAAAAAA;
        end
      end
      REQ_BUS      : begin
        if (pass == 0) begin
          bus_respack = 1;
        end
        else begin
          bus_respack = 0;
        end
      end
      UPDATE_CACHE: begin
				if (bus_respack == 0) begin
        	update_done = 0;
     		end
				else begin
					update_done = 1;
				end
    endcase
  end
  always_ff @(posedge clk) begin
    if (reset) begin
      c_state 	<= INITIAL;
			out_instr	<= 0;
      flag_rdy 	<= 0;
    end
    else begin
      c_state   <= c_next_state;
      out_instr <= curr_instr;
      flag_rdy 	<= update_done;	
    end
  end
  always_comb begin
    case(c_state)
      INIT      : begin
        if (on_req) begin
          c_next_state = BUSY;
        end
      end
      BUSY      : begin
        if (c_hit) begin
          c_next_state = FOUND;
        end
        else begin
          c_next_state = REQ_BUS;
        end
      end
      FOUND      : begin
        if (c_hit) begin
          pass = 1;
        end
        else begin
          pass = 0;
        end
        if (pass) begin
          c_next_state = INITIAL;
        end
      end
      REQ_BUS    : begin
        if (bus_respack) begin
          c_next_state = UPDATE_CACHE;
        end
      end
      UPDATE_CACHE: begin
        if (update_done) begin
          c_next_state = FOUND;
        end
      end
    endcase  
  end
    
endmodule
