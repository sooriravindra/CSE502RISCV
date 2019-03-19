`ifndef REGISTERS_SV
`define REGISTERS_SV

typedef enum {
    zero = 5'b00000,
    ra   = 5'b00001,
    sp   = 5'b00010,
    gp   = 5'b00011,
    tp   = 5'b00100,
    t0   = 5'b00101,
    t1   = 5'b00110,
    t2   = 5'b00111,
    s0   = 5'b01000,
    s1   = 5'b01001,
    a0   = 5'b01010,
    a1   = 5'b01011,
    a2   = 5'b01100,
    a3   = 5'b01101,
    a4   = 5'b01110,
    a5   = 5'b01111,
    a6   = 5'b10000,
    a7   = 5'b10001,
    s2   = 5'b10010,
    s3   = 5'b10011,
    s4   = 5'b10100,
    s5   = 5'b10101,
    s6   = 5'b10110,
    s7   = 5'b10111,
    s8   = 5'b11000,
    s9   = 5'b11001,
    s10  = 5'b11010,
    s11  = 5'b11011,
    t3   = 5'b11100,
    t4   = 5'b11101,
    t5   = 5'b11110,
    t6   = 5'b11111
} register_enum;

logic [63:0] register_file[31:0];

`endif
