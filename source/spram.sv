///
/// ForthSuper Single-Port Memory
///     spram32_32k - 32K  32-bit 
///     spram8_128k - 128K 8-bit (byte)
///
`ifndef FORTHSUPER_SPRAM
`define FORTHSUPER_SPRAM
interface iBus32;
    logic        we;
    logic [3:0]  bmsk;
    logic [14:0] ai;
    logic [31:0] vi;
    logic [31:0] vo;
    modport slave(input we, bmsk, ai, vi, output vo);
endinterface

module spram32_32k (
    iBus32.slave  bus,
    input         clk
    );
    logic [3:0]  msk[1:0];
    logic [15:0] vo16[1:0][1:0];  // 4 16-bit output
    logic cs;           

    SP256K bank00 (
        .AD(bus.ai[13:0]),
        .DI(bus.vi[31:16]),
        .MASKWE(msk[0]),
        .WE(bus.we),
        .CS(~cs),
        .CK(clk),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo16[0][0])
    );
    SP256K bank01 (
        .AD(bus.ai[13:0]),
        .DI(bus.vi[15:0]),
        .MASKWE(msk[1]),
        .WE(bus.we),
        .CS(~cs),
        .CK(clk),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo16[0][1])
    );
    SP256K bank10 (
        .AD(bus.ai[13:0]),
        .DI(bus.vi[31:16]),
        .MASKWE(msk[0]),
        .WE(bus.we),
        .CS(cs),
        .CK(clk),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo16[1][0])
    );
    SP256K bank11 (
        .AD(bus.ai[13:0]),
        .DI(bus.vi[15:0]),
        .MASKWE(msk[1]),
        .WE(bus.we),
        .CS(cs),
        .CK(clk),
        .STDBY(1'b0),
        .SLEEP(1'b0),
        .PWROFF_N(1'b1),
        .DO(vo16[1][1])
    );
    assign msk = {
        {bus.bmsk[3:3], bus.bmsk[3:3], bus.bmsk[2:2], bus.bmsk[2:2]},
        {bus.bmsk[1:1], bus.bmsk[1:1], bus.bmsk[0:0], bus.bmsk[0:0]}
    };
    assign cs     = bus.ai[14:14];
    assign bus.vo = {vo16[cs][0], vo16[cs][1]};
endmodule // spram32_32k
///
/// single byte access for debugging
///
/*
interface iBus8;
    logic we;
    modport slave(input we);
endinterface

module spram8_128k (
	iBus8.slave  bus,
    input        clk,
    input [16:0] ai,     /// 128K depth
    input [7:0]  vi,    /// byte IO
    output logic [7:0] vo
    );
    logic [31:0] vi32, vo32;
    logic [1:0]  b, _b; /// byte index
	iBus32       bus32();
    
    spram32_32k m0(.bus(bus32), .clk);
    
	assign bus32.ai   = ai[16:2];
    assign b          = ai[1:0];
    assign bus32.bmsk = 4'b1 << b;
    assign vi32       = {vi, vi, vi, vi};
    assign vo = _b[1:1]   /// byte mask from previous cycle
            ? (_b[0:0] ? vo32[31:24] : vo32[23:16])
            : (_b[0:0] ? vo32[15:8]  : vo32[7:0]);
    
    always_ff @(posedge clk) begin
        if (!bus.we) _b <= b;   /// read needs to wait for one cycle
    end
endmodule // spram8_128k
*/
`endif // FORTHSUPER_SPRAM


