///
/// @file
/// @brief Single-Port Memory modules 8-bit 128K
///
`ifndef EFORTH1_SPRAM8_128K
`define EFORTH1_SPRAM8_128K
`include "../source/mb8_io.sv"
`include "../source/mb32_io.sv"
`include "../source/spram32_32k.sv"

module spram8_128k (                           /// depth cascade
        mb8_io.slave b8_if
    );
    logic [1:0] m, _m;                         /// byte index of (current and previous cycle)
    /// TODO: add cache

    mb32_io     b32_if(b8_if.clk);
    spram32_32k m0(b32_if.slave);
    ///
    /// 32 to 8-bit converter
    ///
    assign b32_if.we   = b8_if.we;
    assign b32_if.ai   = b8_if.ai[16:2];       /// 32-bit address
    assign b32_if.vi   = {b8_if.vi, b8_if.vi, b8_if.vi, b8_if.vi};
    assign m           = b8_if.ai[1:0];        /// byte select
    assign b32_if.bmsk = m[1:1]                /// write byte select mux
            ? (m[0:0] ? 4'b1000 : 4'b0100)
            : (m[0:0] ? 4'b0010 : 4'b0001);
    assign b8_if.vo    = _m[1:1]               /// read byte mux (from previous cycle)
            ? (_m[0:0] ? b32_if.vo[31:24] : b32_if.vo[23:16])
            : (_m[0:0] ? b32_if.vo[15:8]  : b32_if.vo[7:0]);

    always_ff @(posedge b8_if.clk) begin
        $display("ram32[%x]: {%x}[%x]", b32_if.ai, b32_if.vo, _m);
        _m <= m;                               /// read needs to wait for one cycle
    end
endmodule : spram8_128k

`endif // EFORTH1_SPRAM8_128K
