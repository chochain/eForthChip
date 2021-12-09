///
/// ForthSuper - Comma (add to memory) Module
///
`ifndef FORTHSUPER_COMMA
`define FORTHSUPER_COMMA
`include "../source/forthsuper_if.sv"     /// iBus32 or iBus8 interfaces
typedef enum logic [1:0] { CM0, CM1 } comma_sts;
module comma #(
    parameter DSZ = 8,                    /// 8-bit data path
    parameter ASZ = 17                    /// 128K address path
    ) (
    mb8_io                 mb_if,         /// generic master to drive memory block
    input                  clk,           /// clock
    input                  en,            /// enable
    input [ASZ-1:0]        ai,            /// here: memory address to add code
    input [DSZ-1:0]        vi,            /// value to add
    output logic           bsy,           /// 0:busy, 1:done
    // debug output        
    output                 comma_sts st   /// state: DEBUG
    );
    comma_sts              _st;           /// next state
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
        CM0: _st = en ? CM1 : CM0;
        CM1: _st = CM0;
        default: _st = CM0;
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
        CM0: bsy <= en;
        CM1: bsy <= 1'b0;
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
endmodule: comma
`endif // FORTHSUPER_INNER
