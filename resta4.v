module resta4 (
  input  [3:0] A,
  input  [3:0] B,
  output [3:0] D
);

  wire [3:0] Bnot;
  wire       cout_unused;

  invert4 inv (
    .in(B),
    .out(Bnot)
  );

  adder4 sum (
    .A(A),
    .B(Bnot),
    .Cin(1'b1),
    .S(D),
    .Cout(cout_unused)
  );

endmodule