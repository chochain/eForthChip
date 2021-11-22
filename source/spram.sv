///
/// ForthSuper 32-bit Single-Port Memory (64K block)
///
module spram64k(
    input         clk,
    input         we,
    input [15:0]  a,
    input [31:0]  vi,
    output [31:0] vo
    );
    logic [15:0] vo16 [0:1];        // 2 16-bit output

    assign vo = { vo16[0], vo16[1] };
    
    SP256K bank0 (
        .AD(a[13:0]),
        .DI(vi[31:16]),
        .MASKWE(4'b1111),
        .WE(we),
        .CS(1'b1),
        .CK(clk),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo16[0])
    );
    SP256K bank1 (
        .AD(a[13:0]),
        .DI(vi[15:0]),
        .MASKWE(4'b1111),
        .WE(we),
        .CS(1'b1),
        .CK(clk),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo16[1])
    );
endmodule

