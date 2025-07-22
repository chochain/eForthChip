///
/// @file
/// @brief Single-Port Memory modules 32-bit 32K
///
`include "../verilator/mb32_io.v"

module spram32_32k (             /// width cascade
    mb32_io b32_if               /// 32-bit bus slave
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
