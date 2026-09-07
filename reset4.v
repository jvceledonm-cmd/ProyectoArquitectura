module reset4 (
  output [3:0] R
);
  buf b0 (R[0], 1'b0);
  buf b1 (R[1], 1'b0);
  buf b2 (R[2], 1'b0);
  buf b3 (R[3], 1'b0);
endmodule