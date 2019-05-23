module memory
(
    input  clk,
    input  rst,

    // Input from ALU
    input  [63:0] in_alu_result,
    input  [4:0] in_alu_rd,
    input  [63:0] regB_value,
    input  is_store,
    input  is_load,
    input  [31:0] curr_pc,
    input  is_ecall_alu,
    
    //flush
    input memory_flush,
    //Output to decoder
    output is_mem_busy,
    // Output to writeback
    output [63:0] data_out,
    output [63:0] out_alu_result,
    output [4:0] out_alu_rd,
    output data_valid,
    output [4:0] reg_dest,
    output [31:0] pc_from_mem,
    output is_ecall_mem,
    // Input from cache
    input  [63:0] cache_data,
    input  cache_operation_complete,

    // Output to cache
    output cache_enable,
    output cache_wr_en,
    output [63:0] cache_wr_addr,
    output [63:0] cache_rd_addr,
    output [63:0] cache_wr_value

);

always_ff @(posedge clk) begin
  if(rst) begin
    //rest the pc
    pc_from_mem <= 0;
  end 
  else begin
    //propagate the pc to wb stage
    pc_from_mem <= curr_pc; 
    out_alu_result <= in_alu_result;
    out_alu_rd <= in_alu_rd;
    is_ecall_mem <= is_ecall_alu;
    is_mem_busy <= 0;
    if (is_store) begin
      cache_wr_en <= 1;
      cache_wr_addr <= in_alu_result;
      cache_wr_value <= regB_value;
    end 
    else if(is_load) begin
      cache_wr_en <= 0;
      cache_rd_addr <= in_alu_result;
    end 
    if ((is_store | is_load) & !cache_operation_complete) begin
      cache_enable <= 1;
      is_mem_busy <= 1;
    end 
    else begin
      cache_enable <= 0;
    end
    if(cache_operation_complete) begin
      data_valid <= 1;
      if (is_load) begin
      	reg_dest <= memory_flush ? 5'b00000 : in_alu_rd; 
      	data_out <= cache_data;
      end 
      else if (is_store) begin
      	reg_dest <= 0;
      end
    end
    if (!is_store & !is_load) begin
      data_out <= in_alu_result;
      reg_dest <= memory_flush ? 5'b00000 : in_alu_rd;
      data_valid <= 1;
    end
  end
end

endmodule
