module arbiter
(
    input  clk,
    input  rst,

    //input from caches
    input  [63:0] icache_address,
    input  [63:0] dcache_address,
    input  icache_req,
    input  dcache_req,
    input  wr_en,
    input  [511:0] data_in,

    // output to indicate operation complete to caches
    output [511:0] icache_data_out,
    output [511:0] dcache_data_out, 
    output icache_operation_complete,
    output dcache_operation_complete,
    //cache invalidation instrux to datacache
    output dcache_invalidate,
    output [63:0] dcache_invalidate_addr,

    //input from memory controller
    input [511:0] data_from_mem,
    input mem_data_valid,
    //cache invalidation request from mem_controller
    input invalidate_cache,
    input [63:0] invalidate_cache_addr,

    //output to memory controller
    output [63:0] mem_address,
    output [511:0] mem_data_out,
    output mem_req,
    output mem_wr_en


);

logic prev_is_dcache_req;
logic prev_is_icache_req;
logic is_icache_req;
logic is_dcache_req;
logic is_busy;
logic next_is_busy;
logic next_mem_req;
logic [511:0] next_icache_data_out;
logic [511:0] next_dcache_data_out;
logic [63:0] next_mem_address;
logic next_icache_operation_complete;
logic next_dcache_operation_complete;
logic prev_wr_en;
//handle data invalidation requests
logic next_dcache_invalidate;
logic [63:0] next_dcache_invalidate_addr;

always_comb begin
    next_is_busy = is_busy;
    is_icache_req = prev_is_icache_req;
    is_dcache_req = prev_is_dcache_req;
    if(next_is_busy) begin
        next_mem_req = 0;
        if (wr_en & !prev_wr_en) begin
            next_mem_req = 1;
        end
    end
    if(!dcache_req && !icache_req) begin
        next_is_busy = 0;
    end
    if(!dcache_req) begin
        is_dcache_req = 0;
    end
    if(!icache_req) begin
        is_icache_req = 0;
    end
    // Neither is being served, hence not busy
    if(is_icache_req == 0 && is_dcache_req == 0) begin
        next_is_busy = 0;
    end
    if (icache_req == 1 & next_is_busy == 0) begin
        is_icache_req = 1;
        is_dcache_req = 0;
        next_is_busy = 1;
        next_mem_address = icache_address;
        mem_data_out = 0;
        next_mem_req = 1;
    end
    else if (dcache_req == 1 & next_is_busy == 0) begin
        is_icache_req = 0;
        is_dcache_req = 1;
        next_is_busy = 1;
        next_mem_address = dcache_address;
        mem_data_out = data_in;
        next_mem_req = 1;
    end

    if (dcache_req & wr_en) begin
        mem_wr_en = 1;
    end
    else begin
        mem_wr_en = 0;
    end

    if (mem_data_valid == 1 & is_icache_req == 1) begin
        next_icache_data_out = data_from_mem;
        next_icache_operation_complete = 1;
        next_dcache_operation_complete = 0;
    end
    else if (mem_data_valid == 1 & is_dcache_req == 1) begin
        next_dcache_data_out = data_from_mem;
        next_dcache_operation_complete = 1;
        next_icache_operation_complete = 0;
    end
    else begin
        next_icache_operation_complete = 0;
        next_dcache_operation_complete = 0;
    end

    //cache invalidation handling
    if (invalidate_cache == 1) begin
	next_dcache_invalidate = 1;
	next_dcache_invalidate = invalidate_cache_addr;
    end
end

always_ff @(posedge clk) begin
    mem_req <= next_mem_req;
    is_busy  <= next_is_busy;
    prev_is_icache_req <= is_icache_req;
    prev_is_dcache_req <= is_dcache_req;
    icache_data_out <= next_icache_data_out;
    dcache_data_out <= next_dcache_data_out;
    icache_operation_complete <= next_icache_operation_complete;
    dcache_operation_complete <= next_dcache_operation_complete;
    mem_address <= next_mem_address;
    prev_wr_en <= wr_en;
    //send cache invalidation instrux to dcache
    dcache_invalidate <= next_dcache_invalidate;
    dcache_invalidate_addr <= next_dcache_invalidate_addr;
end

endmodule
