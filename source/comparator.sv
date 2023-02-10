///
/// eForth1 comparator (default 8-bit)
///
`ifndef EFORTH1_COMPARATOR
`define EFORTH1_COMPARATOR
typedef struct packed {
    logic eq, ne, lt, le, gt, ge;
} cmp_t;
    
module comparator #(
    parameter N=8
    ) (
    input  logic s,             /// 0:unsigned, 1:signed
    input  logic [N-1:0] a,     /// operand 0
    input  logic [N-1:0] b,     /// operand 1
    output cmp_t o
    );            /// 6-bit output struct
    
    always_comb begin
        o.eq = (a == b);
        o.ne = (a != b);
        o.lt = s ? ($signed(a) <  $signed(b)) : (a <  b);
        o.le = s ? ($signed(a) <= $signed(b)) : (a <= b);
        o.gt = !o.le;          /// Note: these inverters add extra delay, TODO:
        o.ge = !o.lt;
    end
endmodule: comparator
`endif // EFORTH1_COMPARATOR
