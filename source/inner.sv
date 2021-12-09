///
/// ForthSuper - Mock Inner Interpreter
///
`ifndef FORTHSUPER_INNER
`define FORTHSUPER_INNER
`include "../source/forthsuper_if.sv"     /// iBus32 or iBus8 interfaces
typedef enum logic [1:0] { EX0, EX1, EX2 } inner_sts;
module inner #(
    parameter DSZ = 8,                    /// 8-bit data path
    parameter ASZ = 17                    /// 128K address path
    ) (
    mb8_io                 mb_if,         /// generic master to drive memory block
    input                  clk,           /// clock
    input                  en,            /// enable
    input [ASZ-1:0]        pfa,           /// pfa of the word to execute
    output logic           bsy            /// 0:busy, 1:done
    );
    inner_sts             _st, st;        /// next state
    logic [7:0]            op;
    ///
    /// find - 4-block state machine (Cummings & Chambers)
    /// Note: synchronous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        if (!en) st <= EX0;
        else     st <= _st;
    end
    ///
    /// logic for next state (state diagram)
    ///
    always_comb begin
        case (st)
        EX0: _st = en ? EX1 : EX0;
        EX1: _st = EX2;
        EX2: _st = EX0;
        default: _st = EX0;
        endcase
    end
    ///
    /// logic for next output
    ///
    always_comb begin
        /* mock module, do nothing for now */
    end
    ///
    /// register values for state machine input
    ///
    task step;
        case (st)
        EX0: bsy <= en;
        EX2: bsy <= 1'b0;
        endcase 
    endtask: step
    ///
    /// logic for current output
    /// Note: synchronoous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        if (!en) begin
            /* mock module, do nothing now */
        end
        else step();
    end
endmodule: inner
`endif // FORTHSUPER_INNER
