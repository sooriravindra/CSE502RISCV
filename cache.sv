//`define IDXBITS 14:6
//`define TAGBITS 63:15
//`define OFFBITS 5:
typedef enum {DATA_64, DATA_32, DATA_16} enum_datasize;
module 
cache
#(
  BLOCKSZ      = 64*8,
  WIDTH        = 64,
  NUMLINES     = 512,
  TAGWIDTH     = 49,
  IDXWIDTH     = 9,
  OFFWIDTH     = 6,
  ADDRESSSIZE  = 64
)
(
       input                   clk,
       input                   rst,

       // In from requester
       input                   enable,
       input                   wr_en,
       input [WIDTH-1:0]       data_in,
       input [2:0]              data_size,
       input [ADDRESSSIZE-1:0] r_addr,
       input [ADDRESSSIZE-1:0] w_addr,

       // Out to requester
       output [WIDTH-1:0]      data_out,
       output                  operation_complete,
       output                  mem_fetch,
       // Out to arbiter
       output [ADDRESSSIZE-1:0] mem_address,
       output [BLOCKSZ-1:0]     mem_data_out,
       output                   mem_wr_en,
       output                   mem_req,
       
       // In from arbiter
       input  [BLOCKSZ-1:0]     mem_data_in,
       input                    mem_data_valid

);
enum {INIT, BUSY, FOUND, REQ_BUS, UPDATE_CACHE, START_WRITE} c_state = INIT, c_next_state;

logic                  c_hit, pass, update_done, temp_mem_fetch;
logic [WIDTH-1:0]      final_value;
logic                  final_state;
logic [BLOCKSZ - 1:0]  cachedata [NUMLINES - 1:0];
logic [TAGWIDTH - 1:0] cachetag  [NUMLINES - 1:0];
logic                  cachestate[NUMLINES - 1:0];
logic                  next_mem_req;
logic                  next_mem_wr_en;
logic [ADDRESSSIZE-1:0] cur_mreq_addr; // Address of the current memory request
logic [BLOCKSZ-1:0]     next_mem_data_out;

always_comb begin
  case(c_state) 
    INIT        : begin
        pass         = 0;
        c_hit        = 0;
        update_done  = 0;
        next_mem_req = 0;
        next_mem_wr_en = 0;
        temp_mem_fetch = 0;
    end
    BUSY : begin
        if (wr_en) begin
            //mem_wr_en    = 1; // Will do this after reading if needed
            //mem_data_out = data_in;
            // Treat all writes as Cache hits
            if ((cachestate[w_addr[/*IDXBITS*/14:6]] == 1) & 
                (cachetag[w_addr[/*IDXBITS*/14:6]] == w_addr[63:15/*TAGBITS*/])) begin
                c_hit = 1;
            end
            else begin
                // Set lower 6 bits to zero, we will read the whole cache line
                mem_address = w_addr & 64'hffffffffffffffc0;
                next_mem_wr_en = 0;
                c_hit = 0;
            end
        end
        else begin
            if ((cachestate[r_addr[/*IDXBITS*/14:6]] == 1) & 
                (cachetag[r_addr[/*IDXBITS*/14:6]] == r_addr[63:15/*TAGBITS*/])) begin
                c_hit = 1;
            end
            else begin
                // Set lower 6 bits to zero, we will read the whole cache line
                mem_address = r_addr & 64'hffffffffffffffc0;
                next_mem_wr_en = 0;
                c_hit = 0;
            end
        end
    end
    FOUND : begin
        if (!wr_en) begin
            final_value = cachedata[r_addr[14:6/*IDXBITS*/]][(r_addr[5:0/*OFFBITS*/]*8)+:64];
        end
    end
    REQ_BUS : begin
      temp_mem_fetch = 1;
    end
    UPDATE_CACHE : begin
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

    if (c_state == UPDATE_CACHE) begin
      cachedata[cur_mreq_addr[14:6/*IDXBITS*/]] <= mem_data_in;
      cachestate[cur_mreq_addr[14:6/*IDXBITS*/]] <= 1;
      cachetag [cur_mreq_addr[14:6/*IDXBITS*/]] <= cur_mreq_addr[63:15/*TAGBITS*/];
      update_done = 1;
    end
    else if (c_state == REQ_BUS) begin
      mem_fetch <= temp_mem_fetch;
    end
    else begin
      mem_fetch <= 0;
    end

    
    //if (wr_en) begin
      //cachedata[w_addr[14:6[>IDXBITS*/]][w_addr[5:0/*OFFBITS<]]] <= data_in;
      //cachestate[w_addr[14:6[>IDXBITS<]]] <= final_state;
      //cachetag [w_addr[14:6[>IDXBITS*/]] <= w_addr[63:15/*TAGBITS<]];
      
    //end
    //else if (!enable) begin
        //data_out <= 0;
    //end
    //else 

    if (pass) begin
        data_out <= final_value;
    end
    else begin
        data_out <= 10'h00f;
    end

    c_state <= c_next_state;
    operation_complete <= pass;
    mem_req <= next_mem_req;
    mem_wr_en <= next_mem_wr_en;

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
                next_mem_req = 1;
                cur_mreq_addr = mem_address;
            end
        end
        FOUND: begin
            if (!wr_en) begin
              pass = 1;
              c_next_state = INIT;
            end
            else if (mem_data_valid) begin
                c_next_state = START_WRITE;
            end
            else begin
              pass = 0;
            end
        end
        START_WRITE: begin
            next_mem_req = 1;
            next_mem_wr_en = 1;
            next_mem_data_out = cachedata[w_addr[14:6/*IDXBITS*/]];
            if (mem_data_valid) begin
                c_next_state = INIT;
                pass = 1;
            end
            else begin
                c_next_state = START_WRITE;
                pass = 0;
            end
        end
        REQ_BUS: begin
            // mem_req needs to be high for only one clock cycle
            //next_mem_req = 0; // Take care of this in arbiter
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
