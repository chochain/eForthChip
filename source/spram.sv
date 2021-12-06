///
/// ForthSuper Single-Port Memory
///     spram32_32k - 32K  32-bit 
///     spram8_128k - 128K 8-bit (byte)
///
`ifndef FORTHSUPER_SPRAM
`define FORTHSUPER_SPRAM
`include "../source/forthsuper_if.sv"
module spram32_32k (
    mb32_io b32_if,              /// 32-bit bus slave
    input   clk                  /// memory can be driven with different clock
    );
    logic [3:0]  msk[1:0];
    logic [15:0] vo16[1:0][1:0]; /// 4 16-bit output
    logic cs;           

    SP256K bank00 (
        .AD(b32_if.ai[13:0]),
        .DI(b32_if.vi[31:16]),
        .MASKWE(msk[0]),
        .WE(b32_if.we),
        .CS(~cs),
        .CK(clk),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo16[0][0])
    );
    SP256K bank01 (
        .AD(b32_if.ai[13:0]),
        .DI(b32_if.vi[15:0]),
        .MASKWE(msk[1]),
        .WE(b32_if.we),
        .CS(~cs),
        .CK(clk),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo16[0][1])
    );
    SP256K bank10 (
        .AD(b32_if.ai[13:0]),
        .DI(b32_if.vi[31:16]),
        .MASKWE(msk[0]),
        .WE(b32_if.we),
        .CS(cs),
        .CK(clk),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo16[1][0])
    );
    SP256K bank11 (
        .AD(b32_if.ai[13:0]),
        .DI(b32_if.vi[15:0]),
        .MASKWE(msk[1]),
        .WE(b32_if.we),
        .CS(cs),
        .CK(clk),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo16[1][1])
    );
    assign msk = {
        {b32_if.bmsk[3:3], b32_if.bmsk[3:3], b32_if.bmsk[2:2], b32_if.bmsk[2:2]},
        {b32_if.bmsk[1:1], b32_if.bmsk[1:1], b32_if.bmsk[0:0], b32_if.bmsk[0:0]}
    };
    assign cs        = b32_if.ai[14:14];
    assign b32_if.vo = {vo16[cs][1], vo16[cs][0]};   // slave response
endmodule : spram32_32k
///
/// single byte access for debugging
///
module spram8_128k (
    mb8_io b8_if,
    input  clk
    );
    logic [1:0] m, _m; /// byte index of (current and previous cycle)
    
    mb32_io     b32_if(clk);
    spram32_32k m0(b32_if.slave, clk);
    
    assign m           = b8_if.ai[1:0];
    assign b32_if.we   = b8_if.we;
    assign b32_if.bmsk = 4'b1 << m;
    assign b32_if.ai   = b8_if.ai[16:2];
    assign b32_if.vi   = {b8_if.vi, b8_if.vi, b8_if.vi, b8_if.vi};
    assign b8_if.vo    = _m[1:1]         /// byte mask from previous cycle
            ? (_m[0:0] ? b32_if.vo[31:24] : b32_if.vo[23:16])
            : (_m[0:0] ? b32_if.vo[15:8]  : b32_if.vo[7:0]);
    
    always_ff @(posedge clk) begin
        if (!b8_if.we) _m <= m;          /// read needs to wait for one cycle
    end
endmodule : spram8_128k
`endif // FORTHSUPER_SPRAM
