///
/// ForthSuper comparator (default 32-bit)
///
typedef struct packed {
    logic      eq, neq, lt, lte, gt, gte;
} cmp_t;
    
module comparator #(parameter N=8)
    (a, b, o);
    input  logic [N-1:0]a;
    input  logic [N-1:0]b;
    output              cmp_t o;

    always_comb begin
        o.eq  = (a == b);
        o.neq = (a != b);
        o.lt  = (a <  b);
        o.lte = (a <= b);
        o.gt  = (a >  b);
        o.gte = (a >= b);
    end
endmodule // comparator
