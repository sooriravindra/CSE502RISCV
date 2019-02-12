
module decoder
(
  // 64-bit addresses of the program entry point and initial stack pointer
  input  [63:0] instruction_full
);

    logic [31:0] instruction = instruction_full[31:0];
    logic [6:0] opcode = instruction[6:0];
    logic [2:0] funct3 = instruction[14:12];

    always_comb begin
        case({funct3,opcode})
            10'b0000010011: $display("ADDI");
            default: $display("Unknown instruction");
        endcase
        $display("\n");
    end
          //INITIAL	: begin
                //bus_req 	= pc;
                //bus_reqtag 	= {`SYSBUS_READ, `SYSBUS_MEMORY, 8'h00};
                //bus_reqcyc 	= 1;
          //end
          //WAIT_RESP	: bus_reqcyc 	= 0;
          //GOT_RESP	: bus_respack 	= 1;
          //default	: begin
                //bus_req   	= entry;
        //bus_reqtag 	= {`SYSBUS_READ, `SYSBUS_MEMORY, 8'h00};
        //bus_reqcyc 	= 0;
                //bus_reqcyc 	= 0;
                //bus_respack = 0;
          //end
    //always_ff @ (posedge clk) begin
    //if (reset) begin
      //pc <= entry;
    //end else begin
      ////$display("Hello World!  @ %x", pc);
          //if (bus_reqack == 1 		& next_state == WAIT_RESP & state == INITIAL) begin
                //state <= next_state;		
          //end
          //else if (bus_respcyc == 1 & next_state == GOT_RESP  & state == WAIT_RESP) begin
                //state <= next_state;
          //end
          //else if (bus_respcyc == 0 & next_state == INITIAL & state == GOT_RESP) begin
                //state <= next_state;
          //end
    ////      $finish;
    //end

    ////  initial begin
    ////    $display("Initializing top, entry point = 0x%x", entry);
    //end

    //always_comb begin
        //case(state)
          //INITIAL	: begin 
                //next_state = WAIT_RESP;
          //end
          //WAIT_RESP	: begin 
                //next_state = GOT_RESP;
          //end
          //GOT_RESP	: begin 
                //next_state = INITIAL;
          //end
          //default	: begin 
                //next_state = INITIAL;
          //end
        //endcase
    //end
    initial begin
        $display("Instruction decode");
    end
endmodule
