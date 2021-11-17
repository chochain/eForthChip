///
/// ForthSuper memory (default byte access)
///
module memory #(parameter ASZ=4, parameter DSZ=8, parameter D=$pow(2, ASZ)-1)
    (clk, we, a, i, o);
    input  logic clk;           /// clock
    input  logic we;            /// write enable
    input  logic [ASZ-1:0]a;    /// address
    input  logic [DSZ-1:0]i;    /// input value
    output logic [DSZ-1:0]o;    /// output

    reg [DSZ-1:0] mem[D:0];     /// memory block

    always_ff @(posedge clk) begin
        if (we) mem[a] <= i;
        o <= mem[a];
    end
endmodule // memory
