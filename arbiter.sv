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

    //output to memory controller
    output [63:0] mem_address,
    output [511:0] mem_data_out,
    output mem_req,
    output mem_wr_en,


);
endmodule
