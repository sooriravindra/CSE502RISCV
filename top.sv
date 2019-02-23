
`include "Sysbus.defs"
`include "states.sv"
`include "fetch.sv"
`include "decoder.sv"

module top
#(
  BUS_DATA_WIDTH = 64,
  BUS_TAG_WIDTH = 13
)
(
  input  clk,
         reset,

  // 64-bit addresses of the program entry point and initial stack pointer
  input  [63:0] entry,
  input  [63:0] stackptr,
  input  [63:0] satp,
  
  // interface to connect to the bus
  output bus_reqcyc,
  output bus_respack,
  output [BUS_DATA_WIDTH-1:0] bus_req,
  output [BUS_TAG_WIDTH-1:0] bus_reqtag,
  input  bus_respcyc,
  input  bus_reqack,
  input  [BUS_DATA_WIDTH-1:0] bus_resp,
  input  [BUS_TAG_WIDTH-1:0] bus_resptag
);

  logic [4:0]  decoder_regA;
  logic [11:0] decoder_regB;
  logic [4:0]  decoder_regDest;
  logic [9:0]  decoder_opcode;
  logic [63:0] pc, next_pc; 
  logic [511:0] data_out;
  logic flag_pc_inc;
  integer count, next_count;

  always_comb begin
	case(state)
	  INITIAL	: begin
	  	bus_req 	= pc;
	  	bus_reqtag 	= {`SYSBUS_READ, `SYSBUS_MEMORY, 8'h00};
	  	bus_reqcyc 	= 1;
		bus_respack = 0;
		flag_pc_inc	= 0;
	  end
	  WAIT_RESP	: begin
		bus_reqcyc = 0;
	  end
	  GOT_RESP	: bus_respack = 1;
	  default	: begin
	  	bus_req   	= entry;
      	bus_reqtag 	= {`SYSBUS_READ, `SYSBUS_MEMORY, 8'h00};
      	bus_reqcyc 	= 0;
	  	bus_reqcyc 	= 0;
	  	bus_respack = 0;
	  end
	endcase
  end
  always_ff @ (posedge clk) begin
    if (reset) begin
      pc <= entry;
    end else begin
	  pc <= next_pc;
	  state <= next_state;
	  count <= next_count;
    end
	if ((data_out[7:0] == 0) & pc != 0) begin
          $display(register_file[0]);
          $display(register_file[1]);
          $display(register_file[2]);
          $display(register_file[3]);
          $display(register_file[4]);
          $display(register_file[5]);
          $display(register_file[6]);
          $display(register_file[7]);
          $display(register_file[8]);
          $display(register_file[9]);
          $display(register_file[10]);
          $display(register_file[11]);
          $display(register_file[12]);
          $display(register_file[13]);
          $display(register_file[14]);
          $display(register_file[15]);
          $display(register_file[16]);
          $display(register_file[17]);
          $display(register_file[18]);
          $display(register_file[19]);
          $display(register_file[20]);
          $display(register_file[21]);
          $display(register_file[22]);
          $display(register_file[23]);
          $display(register_file[24]);
          $display(register_file[25]);
          $display(register_file[26]);
          $display(register_file[27]);
          $display(register_file[28]);
          $display(register_file[29]);
          $display(register_file[30]);
          $display(register_file[31]);
          $finish;
	end

  end

  inc_pc pc_add(.pc_in(pc), .next_pc(next_pc), .sig_recvd(flag_pc_inc));
  decoder decoder_instance(.instr(data_out[31:0]), .clk(flag_pc_inc), .rs1(decoder_regA), .rs2(decoder_regB), .rd(decoder_regDest), .opcode(decoder_opcode));
  alu alu_instance(.regA(decoder_regA), .regB(decoder_regB), .opcode(decoder_opcode), .regDest(decoder_regDest), .clk(flag_pc_inc));

  always_comb begin
	case(state)
	  INITIAL	: begin 
		if (bus_reqack) begin
		  next_count = 0;
		  next_state = WAIT_RESP;
		  flag_pc_inc = 0;
		end
	  end
	  WAIT_RESP	: begin
		if (bus_respcyc) begin 
		  next_state = GOT_RESP;
		  flag_pc_inc = 0;
		  if (count == 0) begin
            data_out[count*BUS_DATA_WIDTH +: BUS_DATA_WIDTH] = bus_resp[BUS_DATA_WIDTH - 1 : 0];
			next_count = count + 1;
		  end
		  else begin
			data_out = 0;
		  end
	    end
	  end
	  GOT_RESP	: begin
		if ((bus_respcyc & !flag_pc_inc) | (bus_respcyc == 0 & count == 7)) begin
		  if (count < 8) begin
            data_out[count*BUS_DATA_WIDTH +: BUS_DATA_WIDTH] = bus_resp[BUS_DATA_WIDTH - 1 : 0];
			next_count = count + 1;
		  end
		end
	    else if (!bus_respcyc) begin
		  flag_pc_inc = 1;
		  next_state = INITIAL;
		end	
	  end
	  default	: begin 
		next_state = INITIAL;
	  end
	endcase
  end
endmodule
