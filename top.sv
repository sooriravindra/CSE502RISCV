`include "Sysbus.defs"
`include "states.sv"

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

  logic [63:0] pc;

  always_comb begin
	case(state)
	  INITIAL	: begin
	  	bus_req 	= pc;
	  	bus_reqtag 	= {`SYSBUS_READ, `SYSBUS_MEMORY, 8'h00};
	  	bus_reqcyc 	= 1;
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
	  if (bus_reqack == 1 		& next_state == WAIT_RESP & state == INITIAL) begin
		state <= next_state;		
	  end
	  else if (bus_respcyc == 1 & next_state == GOT_RESP  & state == WAIT_RESP) begin
		state <= next_state;
	  end
	  else if (bus_respcyc == 0 & next_state == INITIAL & state == GOT_RESP) begin
		state <= next_state;
	  end
//      $finish;
    end

//  initial begin
//    $display("Initializing top, entry point = 0x%x", entry);
  end

  always_comb begin
	case(state)
	  INITIAL	: begin 
		next_state = WAIT_RESP;
	  end
	  WAIT_RESP	: begin 
		next_state = GOT_RESP;
	  end
	  GOT_RESP	: begin 
		next_state = INITIAL;
	  end
	  default	: begin 
		next_state = INITIAL;
	  end
	endcase
  end
endmodule
