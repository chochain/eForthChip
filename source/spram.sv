///
/// ForthSuper Single-Port Memory
///     spram32_32k - 32K  32-bit 
///     spram8_128k - 128K 8-bit (byte)
///
`ifndef FORTHSUPER_SPRAM
`define FORTHSUPER_SPRAM
interface iBus32(input logic clk);
    logic        we;
    logic [3:0]  bmsk;
    logic [14:0] ai;
    logic [31:0] vi;
    logic [31:0] vo;
    
    clocking master_cb @(posedge clk);
        default input #1 output #1;
    endclocking // master_cb

    clocking slave_cb @(posedge clk);
        default input #1 output #1;
    endclocking // slave_cb
    
    modport master(clocking master_cb, output we, bmsk, ai, vi);
    modport slave(clocking slave_cb, input we, bmsk, ai, vi, output vo);
endinterface // iBus32

module spram32_32k (
    iBus32.slave b32,
    input        clk               // memory can be driven with different clock
    );
    logic [3:0]  msk[1:0];
    logic [15:0] vo16[1:0][1:0];  // 4 16-bit output
    logic cs;           

    SP256K bank00 (
        .AD(b32.ai[13:0]),
        .DI(b32.vi[31:16]),
        .MASKWE(msk[0]),
        .WE(b32.we),
        .CS(~cs),
        .CK(clk),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo16[0][0])
    );
    SP256K bank01 (
        .AD(b32.ai[13:0]),
        .DI(b32.vi[15:0]),
        .MASKWE(msk[1]),
        .WE(b32.we),
        .CS(~cs),
        .CK(clk),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo16[0][1])
    );
    SP256K bank10 (
        .AD(b32.ai[13:0]),
        .DI(b32.vi[31:16]),
        .MASKWE(msk[0]),
        .WE(b32.we),
        .CS(cs),
        .CK(clk),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo16[1][0])
    );
    SP256K bank11 (
        .AD(b32.ai[13:0]),
        .DI(b32.vi[15:0]),
        .MASKWE(msk[1]),
        .WE(b32.we),
        .CS(cs),
        .CK(clk),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo16[1][1])
    );
    assign msk = {
        {b32.bmsk[3:3], b32.bmsk[3:3], b32.bmsk[2:2], b32.bmsk[2:2]},
        {b32.bmsk[1:1], b32.bmsk[1:1], b32.bmsk[0:0], b32.bmsk[0:0]}
    };
    assign cs     = b32.ai[14:14];
    assign b32.vo = {vo16[cs][1], vo16[cs][0]};
endmodule // spram32_32k
///
/// single byte access for debugging
///
interface iBus8;
    logic        we;
    logic [16:0] ai;
    logic [7:0]  vi;
    logic [7:0]  vo;
    modport master(output we, ai, vi);
    modport slave(input we, ai, vi, output vo);
endinterface

module spram8_128k (
    iBus8.slave  b8,
    input        clk
    );
    logic [1:0] i, _i; /// byte index of (current and previous cycle)
    
    iBus32      b32(clk);
    spram32_32k m0(b32, clk);
    
    assign i        = b8.ai[1:0];
    assign b32.we   = b8.we;
    assign b32.bmsk = 4'b1 << i;
    assign b32.ai   = b8.ai[16:2];
    assign b32.vi   = {b8.vi, b8.vi, b8.vi, b8.vi};
    assign b8.vo    = _i[1:1]   /// byte mask from previous cycle
            ? (_i[0:0] ? b32.vo[31:24] : b32.vo[23:16])
            : (_i[0:0] ? b32.vo[15:8]  : b32.vo[7:0]);
    
    always_ff @(posedge clk) begin
        if (!b8.we) _i <= i;          /// read needs to wait for one cycle
    end
endmodule // spram8_128k
`endif // FORTHSUPER_SPRAM


