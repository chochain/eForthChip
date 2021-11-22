///
/// ForthSuper memory (default byte access)
///
module memory #(
    parameter ASZ=4,            /// address bus size
    parameter DSZ=8,            /// data bus size
    parameter N=16              /// number of cells, TODO: $pow(2,ASZ) does not work
    ) (
    input  logic           clk, /// clock
    input  logic           we,  /// write enable
    input  logic [ASZ-1:0] a,   /// address
    input  logic [DSZ-1:0] vi,  /// input value
    output logic [DSZ-1:0] vo   /// data output
    );
    logic [DSZ-1:0] mem[N-1:0]; /// memory block

    always_ff @(posedge clk) begin
        if (we) mem[a] <= i;
        d <= mem[a];            /// iCE40 EBR is synchronous
    end
endmodule // memory
