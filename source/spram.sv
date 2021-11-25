///
/// ForthSuper Single-Port Memory
///     spram8_128k - 128K 8-bit (byte)
///     spram32_32k - 32K 32-bit 
///
`ifndef FORTHSUPER_SPRAM
`define FORTHSUPER_SPRAM
module spram8_128k (
    input         clk,
    input         we,   /// we:0 read, we:1 write
    input [16:0]  a,    /// 128K depth
    input [7:0]   vi,   /// byte
    output [7:0]  vo
    );
    logic [15:0] vo16[0:3];  /// 16-bit output
    logic [1:0]  cs;

    assign cs = a[2:1];
    
    genvar i;
    for (i = 0; i < 4; i = i + 1) begin : bank
        SP256K m (
            .AD(a[16:3]),
            .DI({vi, vi}),
            .MASKWE({a[0:0], a[0:0], !a[0:0], !a[0:0]}),
            .WE(we),
            .CS(a[2:1]==i),
            .CK(clk),
            .STDBY(1'b0),
            .SLEEP(1'b0),
            .PWROFF_N(1'b1),
            .DO(vo16[i])
        );
    end // block: bank
        
    assign vo = a[0:0] ? vo16[cs][15:8] : vo16[cs][7:0];
endmodule // spram8_128k
/*
module spram32_32k (
    input         clk,
    input         we, /// we:0 read, we:1 write
    input [3:0]   bmsk,
    input [15:0]  a, 
    input [31:0]  vi,
    output [31:0] vo
    );
    logic [15:0] vo16[0:2];  // 2 16-bit output

    SP256K bank0 (
        .AD(a[13:0]),
        .DI(vi[31:16]),
        .MASKWE({bmsk[3:3],bmsk[3:3],bmsk[2:2],bmsk[2:2]}),
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
        .MASKWE({bmsk[1:1],bmsk[1:1],bmsk[0:0],bmsk[0:0]}),
        .WE(we),
        .CS(1'b1),
        .CK(clk),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo16[1])
    );
    
    assign vo = { vo16[0], vo16[1] };
endmodule // spram32_32k
*/
`endif // FORTHSUPER_SPRAM


