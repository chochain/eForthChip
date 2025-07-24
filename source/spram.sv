///
/// @file
/// @brief eforth1 - Single-Port Memory modules
///
///     spram16_64k - 16-bit 64K block
///     spram32_32k - 32-bit 32K block
///     spram8_128k -  8-bit 128K (byte)
///
`ifndef EFORTH1_SPRAM
`define EFORTH1_SPRAM
`include "../source/eforth1_if.sv"

module spram16_64k (
    mb_io b16_if
    );
    logic [15:0] vo16[3:0];              /// 4 16-bit output
    logic [1:0]  cs, _cs;                /// chip select

    assign cs          = b16_if.ai[2:1]; /// distribute access pattern
    assign b16_if.vo   = vo16[_cs];      /// wait one read cycle

    always_ff @(posedge b16_if.clk) begin
        if (!b16_if.we) _cs <= cs;       /// keep cs of previous read cycle
    end

    SP256K bank00 (
        .AD(b16_if.ai[16:3]),
        .DI(b16_if.vi[15:0]),
        .WE(b16_if.we),
        .MASKWE(b16_if.bmsk),
        .CS(cs == 0),
        .STDBY(1'b0),   // (cs != 0) to save power
        .SLEEP(1'b0),   // (cs != 0) to save power
        .PWROFF_N(1'b1),
        .CK(b16_if.clk),
        .DO(vo16[0])
    );
    SP256K bank01 (
        .AD(b16_if.ai[16:3]),
        .DI(b16_if.vi[15:0]),
        .WE(b16_if.we),
        .MASKWE(b16_if.bmsk),
        .CS(cs == 1),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .CK(b16_if.clk),
        .DO(vo16[1])
    );
    SP256K bank10 (
        .AD(b16_if.ai[16:3]),
        .DI(b16_if.vi[15:0]),
        .WE(b16_if.we),
        .MASKWE(b16_if.bmsk),
        .CS(cs == 2),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .CK(b16_if.clk),
        .DO(vo16[2])
    );
    SP256K bank11 (
        .AD(b16_if.ai[16:3]),
        .DI(b16_if.vi[15:0]),
        .WE(b16_if.we),
        .MASKWE(b16_if.bmsk),
        .CS(cs == 3),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .CK(b16_if.clk),
        .DO(vo16[3])
    );
endmodule: spram16_64k

module spram32_32k (             /// width cascade
    mb_io b32_if                 /// 32-bit bus slave
    );
    logic [3:0]  msk[1:0];       /// byte select mask
    logic [15:0] vo16[1:0][1:0]; /// 2x2 16-bit output
    logic cs;

    assign msk = {
        {b32_if.bmsk[3:3], b32_if.bmsk[3:3], b32_if.bmsk[2:2], b32_if.bmsk[2:2]},
        {b32_if.bmsk[1:1], b32_if.bmsk[1:1], b32_if.bmsk[0:0], b32_if.bmsk[0:0]}
    };
    assign cs        = b32_if.ai[14:14];             // select high range
    assign b32_if.vo = {vo16[cs][0], vo16[cs][1]};   // slave response

    SP256K bank00 (
        .AD(b32_if.ai[13:0]),
        .DI(b32_if.vi[31:16]),
        .MASKWE(msk[0]),
        .WE(b32_if.we),
        .CS(~cs),
        .CK(b32_if.clk),
        .STDBY(1'b0),            // STDBY(cs) to save power
        .SLEEP(1'b0),            // SLEEP(cs) to save power
        .PWROFF_N(1'b1),
        .DO(vo16[0][0])
    );
    SP256K bank01 (
        .AD(b32_if.ai[13:0]),
        .DI(b32_if.vi[15:0]),
        .MASKWE(msk[1]),
        .WE(b32_if.we),
        .CS(~cs),
        .CK(b32_if.clk),
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
        .CK(b32_if.clk),
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
        .CK(b32_if.clk),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo16[1][1])
    );
endmodule : spram32_32k
///
/// single byte access for debugging
///
module spram8_128k (   /// depth cascade
    mb8_io b8_if
    );
    logic [1:0] m, _m; /// byte index of (current and previous cycle)

    mb_io #(32) b32_if(b8_if.clk);
    spram32_32k m0(b32_if.slave);

    assign m           = b8_if.ai[1:0];
    assign b32_if.we   = b8_if.we;
    assign b32_if.bmsk = 4'b1 << m;      /// byte per chip
    assign b32_if.ai   = b8_if.ai[16:2];
    assign b32_if.vi   = {b8_if.vi, b8_if.vi, b8_if.vi, b8_if.vi};
    assign b8_if.vo    = _m[1:1]         /// byte mask from previous cycle
            ? (_m[0:0] ? b32_if.vo[31:24] : b32_if.vo[23:16])
            : (_m[0:0] ? b32_if.vo[15:8]  : b32_if.vo[7:0]);

    always_ff @(posedge b8_if.clk) begin
        if (!b8_if.we) _m <= m;          /// read needs to wait for one cycle
    end
endmodule : spram8_128k

`endif // EFORTH1_SPRAM
