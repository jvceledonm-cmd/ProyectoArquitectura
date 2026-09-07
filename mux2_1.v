module mux2_1 (
  input  d0,
  input  d1,
  input  s,
  output y
);
  wire ns, t0, t1;
  not n1 (ns, s);
  and a0 (t0, ns, d0);
  and a1 (t1, s,  d1);
  or  o1 (y, t0, t1);
endmodule