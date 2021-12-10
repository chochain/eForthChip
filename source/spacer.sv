///
/// ForthSuper - TIB space skipper
///
`ifndef FORTHSUPER_SPACER
`define FORTHSUPER_SPACER
`include "../source/forthsuper_if.sv"
typedef enum logic [1:0] { SP0, SP1, SP2 } spc_sts;
module spacer #(
    parameter ASZ = 17              /// return 32-bit integer
    ) (
    mb8_io                 mb_if,   /// memory interface
    input                  clk,     /// clock
    input                  en,      /// enable
    input [ASZ-1:0]        a0,      /// starting TIB address
    input [7:0]            ch,      /// charcter return from memory block
    output logic           bsy      /// 1:busy, 0:done
    );
    spc_sts                _st, st; /// next and current states
    logic [ASZ-1:0]        ai;
    ///
    /// find - 4-block state machine (Cummings & Chambers)
    /// Note: synchronous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        if (!en) st <= SP0;
        else     st <= _st;
    end // always_ff
    ///
    /// logic for next state (state diagram)
    ///
    always_comb begin
        case (st)
        SP0: _st = en  ? SP1 : SP0;    /// look for negative number
        SP1: _st = bsy ? SP2 : SP0;    /// one extra memory cycle wait
        SP2: _st = SP1;
        default: _st = SP0;
        endcase
    end // always_comb
    ///
    /// next output logic - character range check
    ///
    always_comb begin
        /* nothing */
    end // always_comb
    
    task step;
        case (st)
        SP0: if (en) begin
            bsy <= 1'b1;
            mb_if.we <= 1'b0;
            mb_if.ai <= ai;
        end
        SP1: begin
            mb_if.ai <= ai;
        end
        SP2: begin
            mb_if.ai <= ai + (ch == " ");
            bsy <= (ch == " ");
            ai  <= ai + (ch == " ");
        end
        endcase // case (st)
    endtask: step
    ///
    /// logic for current output
    /// Note: synchronoous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        if (!en) begin
            ai <= a0;
        end
        else step();
    end
endmodule: spacer
`endif // FORTHSUPER_SPACER