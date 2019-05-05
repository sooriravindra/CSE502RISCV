module memory_controller
#(
    BUS_DATA_WIDTH = 64,
    BUS_TAG_WIDTH = 13
)
(
    input  clk,
    input  rst,
    input  [63:0] in_address,
    input  [511:0] data_in,
    input  start_req,
    input  wr_en,

    //output data and signal if valid
    output [511:0] data_out,
    output data_valid,

    // interface to connect to the bus follow:

    // Bus inputs
    input  bus_respcyc,
    input  bus_reqack,
    input  [BUS_DATA_WIDTH-1:0] bus_resp,
    input  [BUS_TAG_WIDTH-1:0] bus_resptag,

    // Bus outputs
    output bus_reqcyc,
    output bus_respack,
    output [BUS_DATA_WIDTH-1:0] bus_req,
    output [BUS_TAG_WIDTH-1:0] bus_reqtag

);

logic [511:0] data_out;
logic data_valid;
integer count, next_count;
enum {
    IDLE,
    INIT_REQUEST, 
    WAIT_RESP, 
    GOT_RESP
    } b_state, b_next_state;

always_comb begin
    case(b_state)
        IDLE: begin
        end
        INIT_REQUEST: begin
            bus_req     = in_address;
            if (wr_en) begin
                bus_reqtag  = {`SYSBUS_WRITE, `SYSBUS_MEMORY, 8'h00};
            end
            else begin
                bus_reqtag  = {`SYSBUS_READ, `SYSBUS_MEMORY, 8'h00};
            end
            bus_reqcyc  = start_req;
            bus_respack = 0;
            data_valid = 0;
        end
        WAIT_RESP: begin
            bus_reqcyc = 0;
        end
        GOT_RESP: begin
            bus_respack = 1;
        end
        default: begin
            bus_req     = in_address;
            bus_reqtag  = {`SYSBUS_READ, `SYSBUS_MEMORY, 8'h00};
            bus_reqcyc  = 0;
            bus_reqcyc  = 0;
            bus_respack = 0;
        end
    endcase
end
always_ff @ (posedge clk) begin
    if (rst) begin
        b_state <= INIT_REQUEST;
        count <= 0;
    end
    else begin
        b_state <= b_next_state;
        count <= next_count;
    end
end

always_comb begin
    case(b_state)
        INIT_REQUEST: begin
            if (bus_reqack) begin
                next_count = 0;
                b_next_state = WAIT_RESP;
                data_valid = 0;
            end
        end
        WAIT_RESP: begin
            if (bus_respcyc) begin
                b_next_state = GOT_RESP;
                data_valid = 0;
                if (count == 0) begin
                    data_out[count*BUS_DATA_WIDTH +: BUS_DATA_WIDTH] = bus_resp[BUS_DATA_WIDTH - 1 : 0];
                    next_count = count + 1;
                end
                else begin
                    data_out = 0;
                end
            end
        end
        GOT_RESP: begin
            if ((bus_respcyc & !data_valid) | (bus_respcyc == 0 & count == 7)) begin
                if (count < 8) begin
                    data_out[count*BUS_DATA_WIDTH +: BUS_DATA_WIDTH] = bus_resp[BUS_DATA_WIDTH - 1 : 0];
                    next_count = count + 1;
                end
            end
            else if (!bus_respcyc) begin
                data_valid = 1;
                b_next_state = INIT_REQUEST;
            end
        end
        default: begin
            b_next_state = INIT_REQUEST;
        end
    endcase
end
endmodule
