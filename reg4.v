module reg4 (
  input        clk,
  input        en,
  input  [3:0] d,
  output [3:0] q
);
  reg [3:0] q_r;
  assign q = q_r;

  always @(posedge clk) begin
    if (en)
      q_r <= d;
  end
endmodule