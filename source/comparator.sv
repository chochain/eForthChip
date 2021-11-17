///
/// ForthSuper comparator (default 8-bit)
///
typedef struct packed {
    logic      eq, neq, lt, lte, gt, gte;
} cmp_t;
    
module comparator #(parameter N=8)
    (s, a, b, o);
    input  logic s;             /// 0:unsigned, 1:signed
    input  logic [N-1:0]a;      /// operand 0
    input  logic [N-1:0]b;      /// operand 1
    output       cmp_t o;       /// 6-bit output struct

    always_comb begin
        o.eq  = (a == b);
        o.neq = (a != b);
        o.lt  = s ? ($signed(a) <  $signed(b)) : (a <  b);
        o.lte = s ? ($signed(a) <= $signed(b)) : (a <= b);
        o.gt  = !o.lte;         /// Note: these inverters add one extra delay, TODO:
        o.gte = !o.lt;
    end
endmodule // comparator
