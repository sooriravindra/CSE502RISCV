module 
i_cache
#(
	BLOCKSZ	 = 64*8,
  WIDTH    = 64,
  NUMLINES = 512,
  TAGWIDTH = 49,
  IDXWIDTH = 9,
  OFFWIDTH = 6,
  IDXBITS  = 14:6,
  TAGBITS  = 63:15,
	OFFBITS	 = 5:0,
  INSTSIZE = 32
)
(
    input  logic                  clk,
    input  logic[BLOCKSZ - 1:0]   i_block,
    input  logic                  reset,
    input  logic                  req_recvd,
		input  logic									mem_data_valid,
    output logic[INSTSIZE - 1:0]  out_instr,
    output logic                  flag_rdy,
);
  logic                  c_hit, pass, on_req, update_done;
	logic [WIDTH - 1: 0]	 curr_word;
  logic [NUMLINES - 1:0] value;
  logic [BLOCKSZ - 1:0]  cachedata [NUMLINES - 1:0];
  logic [TAGWIDTH - 1:0] cachetag	 [NUMLINES - 1:0];
  logic                  cachestate[NUMLINES - 1:0];
  logic [INSTSIZE - 1:0] curr_inst;
  enum {INIT, BUSY, FOUND, REQ_BUS, UPDATE_CACHE} c_state = INIT, c_next_state;
  always_comb begin
    case(c_state)
      INIT        : begin
        pass        = 0;
        c_hit       = 0;
        value       = 0;
				on_req			= 0;
				flag_rdy		= 0;
        out_instr   = 0;
        update_done = 0;
				curr_inst		= {32'h00000000, i_block[INSTSIZE - 1:0]};
      end
      BUSY         : begin
        if ((cachestate[curr_inst[IDXBITS]] == 1) & 
						(cachetag[curr_inst[IDXBITS]] == curr_inst[TAGBITS])) begin
          c_hit = 1;
        end
        else begin
          c_hit = 0;
        end
      end
      FOUND        : begin
        if (pass) begin
          // Now that the value is found
          curr_word = cachedata[i_block[IDXBITS]][i_block[OFFBITS]];
        end
        else begin
          curr_word = 64'hAAAAAAAAAAAAAAAA;
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
      flag_rdy 	<= pass;	
    end
  end
  always_comb begin
    case(c_state)
      INIT      : begin
        if (req_recvd) begin
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
        if (mem_data_valid) begin
          pass = 1;
          c_next_state = INITIAL;
        end
        else begin
          pass = 0;
        end
      end
      REQ_BUS    : begin
        if (mem_data_valid) begin
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
