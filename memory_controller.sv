module memory_controller
#(
    BUS_DATA_WIDTH = 64,
    BUS_TAG_WIDTH = 13
)
(
    input  clk,
    input  rst,

    // input from arbiter
    input  [63:0] in_address,
    input  [511:0] data_in,
    input  start_req,
    input  wr_en,

    //output data and signal to arbiter
    output [511:0] data_out,
    output data_valid,
    //in case it encounters a cache invalidation req
    output invalidate_cache,
    output [BUS_DATA_WIDTH-1:0] invalidate_cache_addr,

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

logic [511:0] temp_data_out;
logic next_data_valid;
logic next_invalidate_cache;
logic [BUS_DATA_WIDTH-1:0] next_invalidate_cache_addr;
integer count, next_count;
integer send_count, next_send_count;
enum {
    IDLE,
    INIT_REQUEST, 
    WAIT_RESP, 
    GOT_RESP,
    INVALIDATE_REQ,
    SEND_DATA
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
            next_data_valid = 0;
        end
        WAIT_RESP: begin
            bus_reqcyc = 0;
        end
        GOT_RESP: begin
            bus_respack = 1;
        end
        SEND_DATA: begin
        end
        default: begin
            bus_req     = in_address;
            bus_reqtag  = {`SYSBUS_READ, `SYSBUS_MEMORY, 8'h00};
            bus_reqcyc  = 0;
            bus_respack = 0;
        end
    endcase
end
always_ff @ (posedge clk) begin
    if (rst) begin
        b_state <= INIT_REQUEST;
        count <= 0;
        invalidate_cache <= 0;
	invalidate_cache_addr <= 0;
    end
    else begin
        b_state <= b_next_state;
        count <= next_count;
        send_count <= next_send_count;
        data_valid <= next_data_valid;
        invalidate_cache <= next_invalidate_cache;
	invalidate_cache_addr <= next_invalidate_cache_addr;
        data_out <= temp_data_out;
    end
end

always_comb begin
    case(b_state)
        INIT_REQUEST: begin
            next_invalidate_cache = 0;
            if (bus_reqack) begin
                next_count = 0;
                if (wr_en) begin
                    b_next_state = SEND_DATA;
                    next_send_count = 0;
                end else begin
                    b_next_state = WAIT_RESP;
                end
                next_data_valid = 0;
            end
	    //cache invalidation on receiving bus resptag == 800 :: start
	    if(bus_resptag == 12'h800) begin
		//send the control to INVALIDATE_REQ stage
		b_next_state = INVALIDATE_REQ;
	    end
	    //cache invalidation on receiving bus resptag == 800 :: end
        end
        WAIT_RESP: begin
            if (bus_respcyc) begin
                b_next_state = GOT_RESP;
                next_data_valid = 0;
                if (count == 0) begin
                    temp_data_out[count*BUS_DATA_WIDTH +: BUS_DATA_WIDTH] = bus_resp[BUS_DATA_WIDTH - 1 : 0];
                    next_count = count + 1;
                end
                else begin
                    temp_data_out = 0;
                end
            end
	    //cache invalidation on receiving bus resptag == 800 :: start
	    if(bus_resptag == 12'h800) begin
		//send the control to INVALIDATE_REQ stage
		b_next_state = INVALIDATE_REQ;
	    end
	    //cache invalidation on receiving bus resptag == 800 :: end
        end
        GOT_RESP: begin
            if ((bus_respcyc & !next_data_valid) | (bus_respcyc == 0 & count == 7)) begin
                if (count < 8) begin
                    temp_data_out[count*BUS_DATA_WIDTH +: BUS_DATA_WIDTH] = bus_resp[BUS_DATA_WIDTH - 1 : 0];
                    next_count = count + 1;
                end
            end
            else if (!bus_respcyc) begin
                next_data_valid = 1;
                b_next_state = INIT_REQUEST;
            end
        end
        SEND_DATA: begin
            if (bus_reqack) begin
                if (send_count >= 8) begin
                    bus_reqcyc = 0;
                    b_next_state = INIT_REQUEST;
                    next_data_valid = 1;
                end
                else begin
                    bus_reqcyc = 1;
                    bus_req = data_in[send_count*BUS_DATA_WIDTH+: BUS_DATA_WIDTH];
                    next_send_count = send_count + 1;
                end
            end
        end
        INVALIDATE_REQ: begin
            next_invalidate_cache = 1;
            bus_respack = 1;
	    //send the target addr bus_resp to output for invalidation
	    //the target address in the last 64 bits of the bus_resp
	    //we read that into temp_data_out
	    next_invalidate_cache_addr = bus_resp[BUS_DATA_WIDTH-1:0]; 
            b_next_state = INIT_REQUEST;
        end
        default: begin
            b_next_state = INIT_REQUEST;
        end
    endcase
end
endmodule
