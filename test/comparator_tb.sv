///
/// ForthSuper comparator testbench
///
module comparator_tb #(
    // test parameters
    localparam N   = 32,            /// 32-bit comparator
    localparam LT  = 6'b011100,
    localparam EQ  = 6'b100101,
    localparam GT  = 6'b010011
    );
    integer MAX = $pow(2,N) - 1;    /// so, MAX is not a real number
    // IO
    logic [N-1:0]a;
    logic [N-1:0]b;
    logic [5:0]uo;                  /// unsigned output
    logic [5:0]so;                  /// signed output
    // DUTs
    comparator #(N) dut_u(.s(1'b0), .a, .b, .o(uo));  /// unsigned comparator  
    comparator #(N) dut_s(.s(1'b1), .a, .b, .o(so));  /// signed comparator
    // debug trace
    task check(input [5:0]o, [5:0]v);
        $write("t=%3t, a=%10d[%h] b=%10d[%h], %d[%b] => %d[%b]",
            $time, $signed(a), a, $signed(b), b, o, o, v, v);
        $display(" %s", o===v ? "ok" : "err");
    endtask: check

    initial begin
        //$monitor("t=%04t, a=%h b=%h, eq,neq,lt,lte,qt,qte=%b", $time, a, b, {eq,neq,lt,lte,gt,gte});
        a = 0; b = 1;  #1; check(uo, LT); check(so, LT);   // t1
        a = 1;         #1; check(uo, EQ); check(so, EQ);   // t2
        b = 0;         #1; check(uo, GT); check(so, GT);   // t3
        a = MAX;       #1; check(uo, GT); check(so, LT);   // t4
        b = MAX;       #1; check(uo, EQ); check(so, EQ);   // t5
        a = a - 1;     #1; check(uo, LT); check(so, LT);   // t6
        b = 0;         #1; check(uo, GT); check(so, LT);   // t7
        a = MAX>>1;    #1; check(uo, GT); check(so, GT);   // t8
        b = MAX>>1;    #1; check(uo, EQ); check(so, EQ);   // t9
        a = a - 1;     #1; check(uo, LT); check(so, LT);   // t10
        $finish;
    end
endmodule: comparator_tb
