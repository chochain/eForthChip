///
/// @file
/// @brief Single-Port Memory modules 16-bit 64K
///
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
