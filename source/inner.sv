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
    ss_io                  ds_if,         /// data stack
    input                  clk,           /// clock
    input                  en,            /// enable
    input [ASZ-1:0]        pfa,           /// instruction pointer (pfa of the 1st opcode)
    input [DSZ-1:0]        op,            /// opcode to be executed
    output logic           bsy            /// 0:busy, 1:done
    );
    inner_sts              _st, st;       /// next state
    logic [ASZ-1:0]        ip;
    
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
    /// note: depends on opcode, more cycles might be needed
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
        // mock code, the meat of VM goes here
        case (st)
        EX0: if (en) begin
            bsy = 1'b1;
            $display("t%0d: inner execuating opcode: x%0x", $time, op);
        end
        EX1: begin
            bsy = 1'b1;
            $display("t%0d: inner executing other opcodes - mock", $time);
        end
        EX2: begin
            bsy = 1'b0;
            $display("t%0d: inner done", $time);
        end
        default: bsy = 1'b0;
        endcase // (st)
    end
    ///
    /// register values for state machine input
    ///
    task step;
        /* nothing to do for now */
    endtask: step
    ///
    /// logic for current output
    /// Note: synchronoous reset (TODO: async)
    ///
    always_ff @(posedge clk) begin
        if (!en) begin
            ip <= pfa;
        end
        else step();
    end
endmodule: inner
`endif // FORTHSUPER_INNER
