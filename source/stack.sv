///
/// ForthSuper stack (FILO)
///
`ifndef FORTHSUPER_STACK
`define FORTHSUPER_STACK
`include "../source/forthsuper_if.sv"
module stack #(
    parameter DEPTH = 64,
    parameter DSZ   = 32,
    parameter SSZ   = $clog2(DEPTH),
    parameter NEG1  = DEPTH - 1
    ) (
    ss_io           ss_if,         /// 32-bit stack bus
    input  logic    clk,           /// clock
    input  logic    rst,           /// reset
    input  logic    en             /// enable
    );
    logic [SSZ-1:0] _sp, sp = 0;
    logic [DSZ-1:0] vo;
    ///
    /// instance of EBR Single Port Memory
    ///
    pmi_ram_dq #(DEPTH, SSZ, DSZ, "noreg") ss (    /// noreg saves a cycle
        .Data      (ss_if.vi),
        .Address   (_sp),
        .Clock     (clk),
        .ClockEn   (en),
        .WE        (ss_if.op == PUSH),
        .Reset     (rst),
        .Q         (vo)
    );
    always_comb begin // (sensitivity list: ss_if.op, ss_if.vi, vo)
        case (ss_if.op)
        PUSH: begin _sp = sp + 1'b1; ss_if.s = ss_if.vi; end
        POP:  begin _sp = sp + NEG1; ss_if.s = vo;       end
        default: begin 
            _sp     = sp;
            ss_if.s = vo;
        end
        endcase
    end
    ///
    /// using FF implies a pipedline design
    ///
    always_ff @(posedge clk) begin
        //automatic string op = FS1::Enum2str#(stack_ops)::to_s(ss_if.op);
        $display("%6d: %0s sp=%0d s=%0d ? (vi=%0d : vo=%0d)",
            $time, ss_if.op.name(), sp, $signed(ss_if.s), $signed(ss_if.vi), $signed(vo));
        if (en) sp <= _sp;
    end
endmodule: stack
///
/// Pseudo Dual-port stack (using EBR)
///
/*
module dstack #(
    parameter DEPTH = 64,
    parameter DSZ   = 32,
    parameter SSZ   = $clog2(DEPTH),
    parameter NEG1  = DEPTH - 1
    ) (
    ss_io           ss_if,           /// 32-bit stack bus
    input  logic    clk,             /// clock
    input  logic    rst,             /// reset
    input  logic    en               /// enable
    );
    logic [SSZ-1:0] sp_1, sp = 0;   /// sp_1 = sp - 1
    logic [DSZ-1:0] vo;
    pmi_ram_dp #(
       .pmi_wr_addr_depth(DEPTH),
       .pmi_wr_addr_width(SSZ),
       .pmi_wr_data_width(DSZ),
       .pmi_rd_addr_depth(DEPTH),
       .pmi_rd_addr_width(SSZ),
       .pmi_rd_data_width(DSZ),
       .pmi_regmode("noreg")         // "reg"|"noreg"
       //.pmi_resetmode        ( ),  // "async"|"sync"
       //.pmi_init_file        ( ),  // string
       //.pmi_init_file_format ( ),  // "binary"|"hex"
       //.pmi_family           ( )   // "iCE40UP"|"common"
    ) ss (
       .Data      (ss_if.s),  // TOS (push ready)
       .WrAddress (sp),       // stack top pointer
       .RdAddress (sp_1),     // NOS pointer
       .WrClock   (clk),
       .RdClock   (clk),
       .WrClockEn (1'b1),
       .RdClockEn (1'b1),
       .WE        (ss_if.op == PUSH),
       .Reset     (rst),
       .Q         (vo)        // sp_1
    );
    assign sp_1 = sp + NEG1;
    ///
    /// NOS ready in next cycle
    ///
    always_ff @(posedge clk) begin
        if (en) begin
            case (ss_if.op)
            PUSH: begin
                sp      <= sp + 1'b1;
                ss_if.s <= ss_if.vi;                   // retain TOS
            end
            POP:  begin
                sp      <= sp_1;
                ss_if.s <= (sp_1 == NEG1) ? 'h0 : vo;  // pop NOS into TOS
            end
            READ: begin
                $display("%d <- ss[%x + %x]", vo, sp, ss_if.vi);
            end
            endcase
        end
    end
endmodule: dstack
///
/// Dual-port stack (using 3778 LUTs on iCE40UP5K, too expensive)
///
module dstack #(
    parameter DEPTH = 64,
    parameter DSZ   = 32,
    parameter SSZ   = $clog2(DEPTH),
    parameter NEG1  = DEPTH - 1
    ) (    
    ss_io           ss_if,           /// 32-bit stack bus
    input  logic    clk,             /// clock
    input  logic    rst,             /// reset
    input  logic    en               /// enable
    );
    logic [SSZ-1:0] sp_1, sp = 0;   /// sp_1 = sp - 1
    logic [DSZ-1:0] ram[DEPTH-1:0]; /// memory block 

    always_comb begin
        case (ss_if.op)
        PUSH: begin
            ss_if.s = ss_if.t;
            ss_if.t = ss_if.vi;
        end
        POP: begin
            ss_if.t = ss_if.s;
            ss_if.s = ram[sp_1];
        end
        endcase
        sp_1 = sp + NEG1;
    end
    // writing to the RAM
    Always_ff @(posedge clk) begin
        case (ss_if.op)
        PUSH: begin
            ram[sp] <= ss_if.vi;
            sp      <= sp + 1'b1;
        end
        POP: begin
            sp      <= sp + NEG1;
        end
        endcase
    end
endmodule: dstack
*/
`endif // FORTHSUPER_STACK
