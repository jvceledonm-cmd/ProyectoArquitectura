module mux4_1 (
  input  d0, d1, d2, d3,
  input  s0, s1,
  output y
);
  wire ns0, ns1;
  wire t0, t1, t2, t3;

  not n0 (ns0, s0);
  not n1 (ns1, s1);

  and g0 (t0, ns1, ns0, d0);
  and g1 (t1, ns1, s0,  d1);
  and g2 (t2, s1,  ns0, d2);
  and g3 (t3, s1,  s0,  d3);

  or  o1 (y, t0, t1, t2, t3);
endmodule