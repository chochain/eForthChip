///
/// ForthSuper comparator (default 32-bit)
///
typedef struct packed {
    logic      eq, neq, lt, lte, gt, gte;
} cmp_t;
    
module comparator #(parameter N=8, parameter S=0)
    (a, b, o);
    input  logic [N-1:0]a;      /// operand 0
    input  logic [N-1:0]b;      /// operand 1
    output       cmp_t o;       /// 6-bit output struct

    always_comb begin
        o.eq  = (a == b);
        o.neq = (a != b);
        o.lt  = S ? ($signed(a) <  $signed(b)) : (a <  b);
        o.lte = S ? ($signed(a) <= $signed(b)) : (a <= b);
        o.gt  = !o.lte;
        o.gte = !o.lt;
    end
endmodule // comparator
