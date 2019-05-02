//`define IDXBITS 14:6
//`define TAGBITS 63:15
//`define OFFBITS 5:
module 
cache
#(
  BLOCKSZ  	= 64*8,
  WIDTH    	= 64,
  NUMLINES 	= 512,
  TAGWIDTH 	= 49,
  IDXWIDTH 	= 9,
  OFFWIDTH 	= 6,
  ADDRESSSIZE	= 64
)
(
       input                      		clk,
       input                      		wr_en,
       input        [WIDTH-1:0]   		data_in, 
       input        [ADDRESSSIZE-1:0] r_addr, 
       input        [ADDRESSSIZE-1:0] w_addr, 
       input                      		rst,
       input                      		enable,
       output logic [WIDTH-1:0]   		data_out,
       output logic               		operation_complete,

       // All the following outputs go to the memory module
       output logic [ADDRESSSIZE-1:0] mem_address,
       output logic [WIDTH-1:0]     	mem_data_out,
       output logic                 	mem_wr_en,
       input  logic [BLOCKSZ-1:0]     mem_data_in,
       input  logic                   mem_data_valid

);
enum {INIT, BUSY, FOUND, REQ_BUS, UPDATE_CACHE} c_state = INIT, c_next_state;

logic                  c_hit, pass, update_done ;
logic [NUMLINES - 1:0] value;
logic [WIDTH-1:0] 		 final_value;
logic             		 final_state;
logic [BLOCKSZ - 1:0]  cachedata [NUMLINES - 1:0];
logic [TAGWIDTH - 1:0] cachetag  [NUMLINES - 1:0];
logic                  cachestate[NUMLINES - 1:0];

always_comb begin
  case(c_state) 
    INIT        : begin
        pass    	   = 0;
        c_hit 		   = 0;
        mem_wr_en    	   = 0;
        mem_address    	   = 0;
        update_done 	   = 0;
    end
    BUSY        :  begin
        if (wr_en) begin
            // Treat all writes as Cache hits
            c_hit = 1;
        end
        else begin
            if ((cachestate[r_addr[/*IDXBITS*/14:6]] == 1) & 
                (cachetag[r_addr[/*IDXBITS*/14:6]] == r_addr[63:15/*TAGBITS*/])) begin
                c_hit = 1;
            end
            else begin
                c_hit = 0;
            end
        end
    end
    FOUND        : begin
        if (wr_en) begin
            mem_address  = w_addr; 
            mem_wr_en    = 1;
            mem_data_out = data_in;
        end
        if (pass) begin
            if (wr_en) begin
                final_state = 1;
            end
            else begin
                final_value = cachedata[r_addr[14:6/*IDXBITS*/]][r_addr[5:0/*OFFBITS*/]];
            end
        end
    end
    REQ_BUS      : begin
        mem_address = r_addr;
        mem_wr_en = 0;
    end
    UPDATE_CACHE: begin
      final_value = data_in;
      update_done = 1;
    end
  endcase
end

always_ff @(posedge clk) begin
  if (rst == 1) begin
    data_out <= 0;
    c_state <= INIT;
    operation_complete <= 0;
  end
  else begin

    if (mem_data_valid) begin
      cachedata[mem_address[14:6/*IDXBITS*/]] <= mem_data_in;
      cachestate[mem_address[14:6/*IDXBITS*/]] <= 1;
      cachetag [mem_address[14:6/*IDXBITS*/]] <= mem_address[63:15/*TAGBITS*/];
    end

    if (wr_en) begin
      cachedata[w_addr[14:6/*IDXBITS*/]][w_addr[5:0/*OFFBITS*/]] <= data_in;
      cachestate[w_addr[14:6/*IDXBITS*/]] <= final_state;
      cachetag [w_addr[14:6/*IDXBITS*/]] <= w_addr[63:15/*TAGBITS*/];
      
    end
    else begin
        data_out <= final_value;
    end
    c_state <= c_next_state;
    operation_complete <= pass;
  end
end

always_comb begin
    case(c_state)
        INIT: begin
            if(enable) begin
                c_next_state = BUSY;
            end
        end
        BUSY: begin
            if (c_hit) begin
                c_next_state = FOUND;
            end
            else begin
                c_next_state = REQ_BUS;
            end
        end
        FOUND: begin
            if (!wr_en | mem_data_valid) begin
              pass = 1;
              c_next_state = INIT;
            end
            else begin
              pass = 0;
            end
        end
        REQ_BUS: begin
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
