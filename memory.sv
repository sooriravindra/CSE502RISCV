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
    input  [63:0] in_alu_mem_addr,
    input  [5:0] mem_datasize,
    input  mem_load_sign_extend,
    
    //flush
    input memory_flush,
    //Output to decoder
    output is_mem_busy,
    // Output to writeback
    output [63:0] data_out,
    output [63:0] out_alu_result,
    output [4:0] reg_dest,
    output [31:0] pc_from_mem,
    output is_ecall_mem,
    output ld_or_alu,
    output mem_operation_complete,
    // Input from cache
    input  [63:0] cache_data,
    input  cache_operation_complete,

    // Output to cache
    output cache_wr_en,
    output [63:0] cache_wr_addr,
    output [63:0] cache_rd_addr,
    output [5:0] cache_datasize,
    output [63:0] cache_wr_value

);

logic [4:0] mem_reg_dest;
logic load_operation;
logic is_load_sign_extend;
always_comb begin
    // is_mem_busy
    if ((is_store | is_load) & !cache_operation_complete) begin
        is_mem_busy = 1;
    end 
    else if (cache_operation_complete) begin
        is_mem_busy  = 0;
    end
end
always_ff @(posedge clk) begin
  if(rst) begin
    //rest the pc
    pc_from_mem <= 0;
  end 
  else begin
    //propagate the pc to wb stage
    pc_from_mem <= curr_pc; 
    out_alu_result <= in_alu_result;
    reg_dest <= 0;
    is_ecall_mem <= is_ecall_alu;

    // Cache outputs
    if (is_store) begin
      cache_wr_en <= 1;
      cache_wr_addr <= in_alu_mem_addr;
      cache_wr_value <= in_alu_result;
      cache_datasize <= mem_datasize;
    end 
    else if(is_load) begin
      cache_wr_en <= 0;
      cache_rd_addr <= in_alu_result;
      cache_datasize <= mem_datasize;
    end 




    // Remember the destination register
    if (is_load) begin
      mem_reg_dest <= memory_flush ? 5'b00000 : in_alu_rd; 
      load_operation <= 1;
      is_load_sign_extend <= mem_load_sign_extend;
    end 
    // Memory operations
    if(cache_operation_complete) begin
      ld_or_alu <= 1;
      if (load_operation) begin
      	reg_dest <= memory_flush ? 5'b00000 : mem_reg_dest; 
        if (is_load_sign_extend) begin
            case (cache_datasize)
                DATA_8: begin
                    data_out <= {{56{cache_data[7]}},cache_data[7:0]};
                end
                DATA_16: begin
                    data_out <= {{48{cache_data[15]}},cache_data[15:0]};
                end
                DATA_32: begin
                    data_out <= {{32{cache_data[31]}},cache_data[31:0]};
                end
                DATA_64: begin
                    data_out <= cache_data;
                end
                default: begin
                    data_out <= cache_data;
                end
            endcase
        end
        else begin
            case (cache_datasize)
                DATA_8: begin
                    data_out <= {56'h0,cache_data[7:0]};
                end
                DATA_16: begin
                    data_out <= {48'h0,cache_data[15:0]};
                end
                DATA_32: begin
                    data_out <= {32'h0,cache_data[31:0]};
                end
                DATA_64: begin
                    data_out <= cache_data;
                end
                default: begin
                    data_out <= cache_data;
                end
            endcase
        end
      end 
      else begin
      	reg_dest <= 0;
      end
      load_operation <= 0;
      mem_operation_complete <= 1;
    end
    // ALU operations
    else if (!is_store & !is_load & !is_mem_busy) begin
      ld_or_alu <= 0;
      data_out <= in_alu_result;
      reg_dest <= memory_flush ? 5'b00000 : in_alu_rd;
      mem_operation_complete <= 0;
    end
    else begin
      mem_operation_complete <= 0;
    end
  end
end

endmodule
