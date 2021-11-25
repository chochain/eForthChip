///
/// ForthSuper Single-Port Memory
///     spram32_32k - 32K  32-bit 
///     spram8_128k - 128K 8-bit (byte)
///
`ifndef FORTHSUPER_SPRAM
`define FORTHSUPER_SPRAM
module spram32_32k (
    input         clk,
    input         we,         /// we:0 read, we:1 write
    input [3:0]   bmsk,
    input [14:0]  a,          /// 32K depth
    input [31:0]  vi,
    output [31:0] vo
    );
    logic [15:0] vo16[1:0][1:0];  // 4 16-bit output
    logic cs;           

    SP256K bank00 (
        .AD(a[13:0]),
        .DI(vi[31:16]),
        .MASKWE({bmsk[3:3],bmsk[3:3],bmsk[2:2],bmsk[2:2]}),
        .WE(we),
        .CS(~cs),
        .CK(clk),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo16[0][0])
    );
    SP256K bank01 (
        .AD(a[13:0]),
        .DI(vi[15:0]),
        .MASKWE({bmsk[1:1],bmsk[1:1],bmsk[0:0],bmsk[0:0]}),
        .WE(we),
        .CS(~cs),
        .CK(clk),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo16[0][1])
    );
    SP256K bank10 (
        .AD(a[13:0]),
        .DI(vi[31:16]),
        .MASKWE({bmsk[3:3],bmsk[3:3],bmsk[2:2],bmsk[2:2]}),
        .WE(we),
        .CS(cs),
        .CK(clk),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo16[1][0])
    );
    SP256K bank11 (
        .AD(a[13:0]),
        .DI(vi[15:0]),
        .MASKWE({bmsk[1:1],bmsk[1:1],bmsk[0:0],bmsk[0:0]}),
        .WE(we),
        .CS(cs),
        .CK(clk),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo16[1][1])
    );
    assign cs = a[14:14];
    assign vo = {vo16[cs][0], vo16[cs][1]};
endmodule // spram32_32k
/*
module spram8_128k (
    input         clk,
    input         we,   /// we:0 read, we:1 write
    input [16:0]  a,    /// 128K depth
    input [7:0]   vi,   /// byte IO
    output logic [7:0]  vo
    );
    logic [31:0] vi32, vo32[0:1];
    logic [3:0]  bmsk;
    logic [1:0]  b;
    logic cs;
    
    spram32_64k m0(clk, we, bmsk[0], a[16:3], vi32, vo32[0]);
    
    assign vi32 = { vi, vi, vi, vi };
    assign cs   = a[2:2];
    assign b    = a[1:0];
    assign bmsk[0] = cs ? 4'b0 : (4'b1 << b);
    assign bmsk[1] = cs ? (4'b1 << b) : 4'b0;
    
    always_ff @(posedge clk) begin
        vo <= b[1:1] 
        ? (b[0:0] ? vo32[cs][31:24] : vo32[cs][23:16])
        : (b[0:0] ? vo32[cs][15:8]  : vo32[cs][7:0]);
    end
endmodule // spram8_128k
*/
`endif // FORTHSUPER_SPRAM


