///
/// ForthSuper stack (FILO)
///
module stack #(
    parameter DSZ   = 32,         /// data bus size
    parameter DEPTH = 16,
    parameter ISZ   = $clog2(DEPTH) - 1
    ) (
    input  logic           clk,   /// clock
    input  logic           we,    /// 1:push, 0:pop
    input  logic [DSZ-1:0] vi,    /// push value
    output logic           e,     /// empty
    output logic           f,     /// full
    output logic [DSZ-1:0] vo     /// return value (top of stack)
    );    
    reg [ISZ:0]   idx;            /// stack index
    reg [DSZ-1:0] ss[DEPTH-1:0];  /// memory block
    
    always_ff @(posedge clk) begin
        if (we) begin
            ss[idx] <= vi;
            idx     <= idx==(DEPTH - 1) ? idx : idx + 1;
            e       <= 0;
            f       <= idx==(DEPTH - 1);
        end
        else begin
            vo      <= ss[idx - 1];
            idx     <= idx ? idx - 1 : 0;
            e       <= (idx==0);
            f       <= 0;
        end
    end
endmodule // stack
//
// bit-slice
//
module stack2 #(
    parameter DSZ   = 32,
    parameter DEPTH = 16
    ) (
    input wire            clk,
    input wire            we,
    input wire [1:0]      delta,
    input wire [DSZ-1:0]  vi,
    output wire [DSZ-1:0] vo
    );
    localparam BITS = (DSZ * DEPTH) - 1;

    reg [DSZ-1:0] tos, _tos;
    reg [BITS:0]  ss,  _ss;
    wire          mv = delta[0];

    assign _tos = we ? vi : ss[DSZ-1:0];
    assign _ss  = delta[1] ? {16'h55aa, ss[BITS:DSZ]} : {ss[BITS-DSZ:0], tos};

    always @(posedge clk) begin
        if (we | mv)
            tos <= _tos;
        if (mv)
            ss <= _ss;
    end

    assign vo = tos;
endmodule

module stack3 #(
    parameter DEPTH = 64,
    parameter DSZ   = 32,
    parameter SSZ   = $clog2(DEPTH)
    ) (
    input  logic           clk,   /// clock
    input  logic           push,
    input  logic           pop,
    input  logic [DSZ-1:0] vi,    /// push value
    output logic [DSZ-1:0] vo     /// return value (top of stack)
    );
    logic we;
    logic [SSZ-1:0] idx;
    stack64 data(
        .clk_i(clk),
        .rst_i(1'b0),
        .clk_en_i(1'b1),
        .wr_en_i(we),
        .wr_data_i(vi),
        .addr_i(idx),
        .rd_data_o(vo)
    );
    
    always_ff @(posedge clk) begin
        if (push) begin
            we  <= 1;
            idx <= idx + 6'b1;
        end    
        else begin
            we <= 0;
            if (pop) idx <= idx - 6'b1;
        end 
    end
endmodule // stack3