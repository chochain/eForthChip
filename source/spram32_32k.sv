///
/// @file
/// @brief Single-Port Memory modules 32-bit 32K
///
`ifndef EFORTH1_SPRAM32_32K
`define EFORTH1_SPRAM32_32K

module spram32_32k (                 /// width cascade
        mb32_io.slave b32_if         /// 32-bit bus slave
    );
    logic [3:0]  msk0, msk1;         /// byte select mask
    logic [31:0] vo32a, vo32b;
    logic cs;

    assign cs   = b32_if.ai[14:14];   ///< select high range
    assign msk0 = {                   ///< write nibble select
        b32_if.bmsk[1:1], b32_if.bmsk[1:1], b32_if.bmsk[0:0], b32_if.bmsk[0:0]
    };
    assign msk1 =  {
        b32_if.bmsk[3:3], b32_if.bmsk[3:3], b32_if.bmsk[2:2], b32_if.bmsk[2:2]
    };
    assign b32_if.vo = cs ? vo32b : vo32a;
   
//    always_ff @(posedge b32_if.clk) begin
//       b32_if.vo <= cs ? vo32b : vo32a;     /// latch needed? (says yosys)
//    end

    SP256K bank00 (
        .AD(b32_if.ai[13:0]),
        .DI(b32_if.vi[15:0]),
        .MASKWE(msk0),
        .WE(b32_if.we),
        .CS(~cs),
        .CK(b32_if.clk),
        .STDBY(1'b0),                /// STDBY(cs) to save power
        .SLEEP(1'b0),                /// SLEEP(cs) to save power
        .PWROFF_N(1'b1),             /// POWER on
        .DO(vo32a[15:0])
    );
    SP256K bank01 (
        .AD(b32_if.ai[13:0]),
        .DI(b32_if.vi[31:16]),
        .MASKWE(msk1),
        .WE(b32_if.we),
        .CS(~cs),
        .CK(b32_if.clk),
        .STDBY(1'b0),                /// can use cs to save power
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo32a[31:16])
    );
    SP256K bank10 (
        .AD(b32_if.ai[13:0]),
        .DI(b32_if.vi[15:0]),
        .MASKWE(msk0),
        .WE(b32_if.we),
        .CS(cs),
        .CK(b32_if.clk),
        .STDBY(1'b0),                /// can use ~cs to save power
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo32b[15:0])
    );
    SP256K bank11 (
        .AD(b32_if.ai[13:0]),
        .DI(b32_if.vi[31:16]),
        .MASKWE(msk1),
        .WE(b32_if.we),
        .CS(cs),
        .CK(b32_if.clk),
        .STDBY(1'b0),                /// can use ~cs to save power
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo32b[31:16])
    );
endmodule : spram32_32k

`endif // EFORTH1_SPRAM32_32K
