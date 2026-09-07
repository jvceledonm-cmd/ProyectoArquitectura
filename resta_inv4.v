module resta_inv4 (
  input  [3:0] A,
  input  [3:0] B,
  output [3:0] D
);

  resta4 nucleo (
    .A(B),
    .B(A),
    .D(D)
  );

endmodule