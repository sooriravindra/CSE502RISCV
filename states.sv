typedef enum {INITIAL, WAIT_RESP, GOT_RESP} Bus_State;
Bus_State b_state, b_next_state;

typedef enum {INIT, BUSY, FOUND, REQ_BUS, UPDATE_CACHE} Cache_states;
Cache_states c_state, c_next_state;
