///
/// ForthSuper Single-Port Memory
///     spram32_32k - 32K  32-bit 
///     spram8_128k - 128K 8-bit (byte)
///
`ifndef FORTHSUPER_SPRAM
`define FORTHSUPER_SPRAM
module spram32_32k (
    input         clk,
    input         we,    /// we:0 read, we:1 write
    input [3:0]   bmsk,
    input [14:0]  a,     /// 32K depth
    input [31:0]  vi,
    output [31:0] vo
    );
    logic [15:0] vo16[1:0][1:0];  // 4 16-bit output
    logic cs;           

    SP256K bank00 (
        .AD(a[13:0]),
        .DI(vi[31:16]),
        .MASKWE({bmsk[3:3], bmsk[3:3], bmsk[2:2], bmsk[2:2]}),
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
        .MASKWE({bmsk[1:1], bmsk[1:1], bmsk[0:0], bmsk[0:0]}),
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
        .MASKWE({bmsk[3:3], bmsk[3:3], bmsk[2:2], bmsk[2:2]}),
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
        .MASKWE({bmsk[1:1], bmsk[1:1], bmsk[0:0], bmsk[0:0]}),
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
///
/// single byte access for debugging
///
module spram8_128k (
    input        clk,
    input        we,    /// we:0 read, we:1 write
    input [16:0] a,     /// 128K depth
    input [7:0]  vi,    /// byte IO
    output logic [7:0] vo
    );
    logic [31:0] vi32, vo32;
    logic [1:0]  b, _b; /// byte index
    logic [3:0]  bmsk;  /// decoder
    
    spram32_32k m0(clk, we, bmsk, a[16:2], vi32, vo32);
    
    assign vi32 = {vi, vi, vi, vi};
    assign b    = a[1:0];
    assign bmsk = 4'b1 << b;
    assign vo   = _b[1:1]   /// byte mask from previous cycle
            ? (_b[0:0] ? vo32[31:24] : vo32[23:16])
            : (_b[0:0] ? vo32[15:8]  : vo32[7:0]);
    
    always_ff @(posedge clk) begin
        if (!we) _b <= b;   /// read needs to wait for one cycle
    end
endmodule // spram8_128k
`endif // FORTHSUPER_SPRAM


