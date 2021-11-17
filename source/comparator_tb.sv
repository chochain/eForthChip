///
/// ForthSuper comparator testbench
///
module comparator_tb #(
    parameter N   = 32,           /// 32-bit comparator
    parameter MAX = $pow(2,N) - 1 /// upper limit
    );
    logic [N-1:0]a;
    logic [N-1:0]b;
    logic [5:0]o;                 /// ModelSim does not like types from other file, TODO:
    
    comparator #(N) dut(.a, .b, .o);  /// instantiate a comparator  

    task check(input [5:0]v); begin
        #1; 
        $write("t=%04t, a=%h b=%h, %b==%b", $time, a, b, o, v);
        $display(" %s", o==v ? "ok" : "err");
    end
    endtask

    initial begin
        //$monitor("t=%04t, a=%h b=%h, eq,neq,lt,lte,qt,qte=%b", $time, a, b, {eq,neq,lt,lte,gt,gte});
        a = 0; b = 1;          check(6'b011100);
        a = 1;                 check(6'b100101);
        b = 0;                 check(6'b010011);
        a = MAX;               check(6'b010011);
        b = MAX;               check(6'b100101);
        a = MAX - 1;           check(6'b011100);
        b = 0;                 check(6'b010011);
        $stop;
    end
endmodule // comparator_tb
