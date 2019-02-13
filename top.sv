
`include "Sysbus.defs"
`include "states.sv"
`include "fetch.sv"

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

  logic [63:0] pc, next_pc, data_out;
  logic flag;

  always_comb begin
	case(state)
	  INITIAL	: begin
	  	bus_req 	= pc;
	  	bus_reqtag 	= {`SYSBUS_READ, `SYSBUS_MEMORY, 8'h00};
	  	bus_reqcyc 	= 1;
		bus_respack = 0;
	  end
	  WAIT_RESP	: bus_reqcyc 	= 0;
	  GOT_RESP	: bus_respack 	= 1;
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
      //$display("Hello World!  @ %x", pc);
	  pc <= next_pc;
	  state <= next_state;
//      $finish;
    end

//  initial begin
//    $display("Initializing top, entry point = 0x%x", entry);
  end

  inc_pc pc_add(.pc_in(pc), .next_pc(next_pc), .sig_recvd(flag));

  always_comb begin
	case(state)
	  INITIAL	: begin 
		if (bus_reqack) begin
		  next_state = WAIT_RESP;
		end
	  end
	  WAIT_RESP	: begin
		if (bus_respcyc) begin 
		  next_state = GOT_RESP;
		  flag = 1;
	    end
	  end
	  GOT_RESP	: begin
		if (bus_respcyc & flag) begin
		  for (int i = 0; i < BUS_DATA_WIDTH/8; i += 1) begin
            data_out[i*BUS_DATA_WIDTH +: BUS_DATA_WIDTH] = bus_resp[BUS_DATA_WIDTH - 1 : 0];
          end
        end	
		else if (!bus_respcyc) begin
		  next_state = INITIAL;
		end
	  end
	  default	: begin 
		next_state = INITIAL;
	  end
	endcase
  end
endmodule
