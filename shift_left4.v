module shift_left4 (
  input  [3:0] A,
  input  [3:0] B,
  output [3:0] Y
);

  mux4_1 m0 (
    .d0(A[0]), .d1(1'b0), .d2(1'b0), .d3(1'b0),
    .s0(B[0]), .s1(B[1]), .y(Y[0])
  );
  mux4_1 m1 (
    .d0(A[1]), .d1(A[0]), .d2(1'b0), .d3(1'b0),
    .s0(B[0]), .s1(B[1]), .y(Y[1])
  );
  mux4_1 m2 (
    .d0(A[2]), .d1(A[1]), .d2(A[0]), .d3(1'b0),
    .s0(B[0]), .s1(B[1]), .y(Y[2])
  );
  mux4_1 m3 (
    .d0(A[3]), .d1(A[2]), .d2(A[1]), .d3(A[0]),
    .s0(B[0]), .s1(B[1]), .y(Y[3])
  );

endmodule