// my_module.v (Your Verilog module)
module my_module (
  input clk,
  input rst,
  input [7:0] data_in,
  output reg [7:0] data_out
);

always @(posedge clk or posedge rst) begin
  if (rst) begin
    data_out <= 8'h00;
  end else begin
    data_out <= data_in + 1;
  end
end

endmodule
