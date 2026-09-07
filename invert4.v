module invert4 (
  input  [3:0] in,
  output [3:0] out
);
  not n0 (out[0], in[0]);
  not n1 (out[1], in[1]);
  not n2 (out[2], in[2]);
  not n3 (out[3], in[3]);
endmodule