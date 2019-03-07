module memory_fetch
#(
    BUS_DATA_WIDTH = 64,
    BUS_TAG_WIDTH = 13
)
(
    input  clk,
    input  [63:0] in_address,
    //output data and signal if valid
    output [511:0] data_out,
    output data_valid,
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

logic [63:0] pc, next_pc; 
logic [511:0] data_out;
logic flag_pc_inc;
integer count, next_count;

always_comb begin
    case(b_state)
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
        b_state <= b_next_state;
        count <= next_count;
    end
end

always_comb begin
    case(b_state)
        INITIAL	: begin 
            if (bus_reqack) begin
                next_count = 0;
                b_next_state = WAIT_RESP;
                flag_pc_inc = 0;
            end
        end
        WAIT_RESP	: begin
            if (bus_respcyc) begin 
                b_next_state = GOT_RESP;
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
                b_next_state = INITIAL;
            end	
        end
        default	: begin 
            b_next_state = INITIAL;
        end
    endcase
end
e
