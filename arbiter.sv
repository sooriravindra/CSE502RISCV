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

    //input from memory controller
    input [511:0] data_from_mem,
    input mem_data_valid,

    //output to memory controller
    output [63:0] mem_address,
    output [511:0] mem_data_out,
    output mem_req,
    output mem_wr_en


);

logic is_icache_req;
logic is_dcache_req;
logic is_busy;
logic next_is_busy;
logic next_mem_req;

always_comb begin
    next_is_busy = is_busy;
    if (icache_req == 1 & next_is_busy == 0) begin
        is_icache_req = 1;
        is_dcache_req = 0;
        next_is_busy = 1;
        mem_address = icache_address;
        mem_data_out = 0;
        next_mem_req = 1;
        mem_wr_en = 0;
    end
    else if (dcache_req == 1 & next_is_busy == 0) begin
        is_icache_req = 0;
        is_dcache_req = 1;
        next_is_busy = 1;
        mem_address = dcache_address;
        mem_data_out = data_in;
        next_mem_req = 1;
        mem_wr_en = wr_en;
    end
    else begin
        is_icache_req = 0;
        is_dcache_req = 0;
        next_is_busy = 0;
        mem_address = 0;
        next_mem_req = 0;
        mem_wr_en = 0;
        mem_data_out = 0;
    end

    if (mem_data_valid == 1 & is_icache_req == 1) begin
        icache_data_out = data_from_mem;
        icache_operation_complete = 1;
        dcache_operation_complete = 0;
    end
    else if (mem_data_valid == 1 & is_dcache_req == 1) begin
        dcache_data_out = data_from_mem;
        dcache_operation_complete = 1;
        icache_operation_complete = 0;
    end
    else begin
        icache_operation_complete = 0;
        dcache_operation_complete = 0;
    end
end

always_ff @(posedge clk) begin
    mem_req <= next_mem_req;
    is_busy  <= next_is_busy;
end

endmodule
