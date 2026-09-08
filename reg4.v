module reg4 (
  input        clk,
  input        en,
  input  [3:0] d,
  output [3:0] q
);

  dff_en bit0 (
    .clk(clk),
    .en(en),
    .d(d[0]),
    .q(q[0])
  );

  dff_en bit1 (
    .clk(clk),
    .en(en),
    .d(d[1]),
    .q(q[1])
  );

  dff_en bit2 (
    .clk(clk),
    .en(en),
    .d(d[2]),
    .q(q[2])
  );

  dff_en bit3 (
    .clk(clk),
    .en(en),
    .d(d[3]),
    .q(q[3])
  );

endmodule


module dff_en (
  input  clk,
  input  en,
  input  d,
  output q
);

  SB_DFFE flip_flop (
    .C(clk),
    .E(en),
    .D(d),
    .Q(q)
  );

endmodule