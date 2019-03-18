module 
dcache(
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
	if (wr_en) begin
		addr_out = w_addr;
	end
	else begin
		addr_out = r_addr;
	end
end

endmodule
