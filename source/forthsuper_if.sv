///
/// ForthSuper common interfaces
///
`ifndef FORTHSUPER_FORTHSUPER_IF
`define FORTHSUPER_FORTHSUPER_IF

interface mb32_io(input logic clk);
    logic        we;
    logic [3:0]  bmsk;
    logic [14:0] ai;
    logic [31:0] vi;
    logic [31:0] vo;
    
    clocking ioDrv @(posedge clk);
        default input #1 output #1;
    endclocking // ioMaster

    modport master(clocking ioDrv, output we, bmsk, ai, vi);
    modport slave(clocking ioDrv, input we, bmsk, ai, vi, output vo);
endinterface: mb32_io

interface mb8_io;
    logic        we;
    logic [16:0] ai;
    logic [7:0]  vi;
    logic [7:0]  vo;
    
    modport master(output we, ai, vi, import put_u8);
    modport slave(input we, ai, vi, output vo, import put_u8, get_u8);

    task put_u8([16:0] ax, [7:0] vx);
        we = 1'b1;
        ai = ax;
        vi = vx;
    endtask
    
    task get_u8([16:0] ax);
        we = 1'b0;
        ai = ax;
        // return vo
    endtask
endinterface : mb8_io

interface ss_io();
    logic [1:0]  op;
    logic [31:0] vi;
    logic [31:0] s;
    
    modport master(input s, output op, vi);
    modport slave(input op, vi, output s);

    task push(input [31:0] v);
        op  = 2'b0;   // PUSH, TODO: use enum
        vi  = v;
    endtask: push

    function logic [31:0] pop;
        op   = 2'b1;  // POP, TODO: use enum
        pop  = s;
    endfunction: pop
    
    function logic [31:0] tail;
        op   = 2'b10;  // READ, TODO: use enum
        tail = s;
    endfunction: tail
endinterface: ss_io
`endif // FORTHSUPER_FORTHSUPER_IF

