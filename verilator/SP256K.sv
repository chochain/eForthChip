///
/// @file
/// @brief ICE40 Single-Port Memory modules 16-bit 16K (from ice40/cell_sim.v)
///
`ifndef EFORTH1_SP256K
`define EFORTH1_SP256K

module SP256K (
    input [13:0] AD,
    input [15:0] DI,
    input [3:0]  MSKWE,
    input WE, CS, CK, STDBY, SLEEP, PWROFF_N,
    output reg [15:0] DO
);
`ifdef SYNTHESIS
    SB_SPRAM256KA mem(                     /// using yosys cell_sim
        AD, DI, MSKWE, 
        WE, CS, CK, STDBY, SLEEP,
        ~PWROFF_N,
        DO
    );
   
`else // !SYNTHESIS
    logic [15:0] mem [0:16383];
    logic        off;
   
//    integer i;                          // init randomize (not needed)
//    always @(negedge PWROFF_N) begin
//        for (i = 0; i <= 16383; i++)
//            mem[i] = 16'bx;
//    end
    assign off = SLEEP || ~PWROFF_N;

    always @(posedge CK, posedge off) begin
        if (off) begin
            DO <= 0;
        end else
        if (STDBY) begin
            DO <= 16'hfeed;
        end else
        if (CS) begin
            if (WE) begin
                if (MSKWE[0]) mem[AD][ 3: 0] <= DI[ 3: 0];
                if (MSKWE[1]) mem[AD][ 7: 4] <= DI[ 7: 4];
                if (MSKWE[2]) mem[AD][11: 8] <= DI[11: 8];
                if (MSKWE[3]) mem[AD][15:12] <= DI[15:12];
                DO <= 16'hbeef;
            end else begin
                DO <= mem[AD];
            end
        end
//        $display("%m MASKWE=%b, WE=%x,CS=%x, DI=%x, DO=%x", MASKWE, WE, CS, DI, DO);
    end // always @ (posedge CK, posedge off)
`endif
   
endmodule // SP256K

`endif // EFORTH1_SP256K

