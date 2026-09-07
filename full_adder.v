module full_adder (
  input  A,
  input  B,
  input  Cin,
  output S,
  output Cout
);

  wire axorb;
  wire ab;
  wire cin_axorb;

  // S = (A xor B) xor Cin
  xor g_xor1 (axorb, A, B);
  xor g_xor2 (S, axorb, Cin);

  // Cout = (A and B) or (Cin and (A xor B))
  and g_and1 (ab, A, B);
  and g_and2 (cin_axorb, Cin, axorb);
  or  g_or1  (Cout, ab, cin_axorb);

endmodule