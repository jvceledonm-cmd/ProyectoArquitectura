module alu4 (
  input  [3:0] A,
  input  [3:0] B,
  input  [2:0] codigo,
  output [3:0] R
);

  wire [3:0] r_rst, r_sum, r_sub, r_inv, r_shl, r_shr;
  wire       cout_unused;

  wire c2, c1, c0;
  wire nc2, nc1, nc0;
  wire z000, z001, z010, z011, z100, z101;

  assign c2 = codigo[2];
  assign c1 = codigo[1];
  assign c0 = codigo[0];

  not n2 (nc2, c2);
  not n1 (nc1, c1);
  not n0 (nc0, c0);

  and d000 (z000, nc2, nc1, nc0);
  and d001 (z001, nc2, nc1, c0);
  and d010 (z010, nc2, c1,  nc0);
  and d011 (z011, nc2, c1,  c0);
  and d100 (z100, c2,  nc1, nc0);
  and d101 (z101, c2,  nc1, c0);

  reset4      u_rst (.R(r_rst));
  adder4      u_sum (.A(A), .B(B), .Cin(1'b0), .S(r_sum), .Cout(cout_unused));
  resta4      u_sub (.A(A), .B(B), .D(r_sub));
  resta_inv4  u_inv (.A(A), .B(B), .D(r_inv));
  shift_left4 u_shl (.A(A), .B(B), .Y(r_shl));
  shift_right4 u_shr (.A(A), .B(B), .Y(r_shr));

  wire [3:0] t0, t1, t2, t3, t4, t5;

  and a00 (t0[0], z000, r_rst[0]);
  and a01 (t0[1], z000, r_rst[1]);
  and a02 (t0[2], z000, r_rst[2]);
  and a03 (t0[3], z000, r_rst[3]);

  and a10 (t1[0], z001, r_sum[0]);
  and a11 (t1[1], z001, r_sum[1]);
  and a12 (t1[2], z001, r_sum[2]);
  and a13 (t1[3], z001, r_sum[3]);

  and a20 (t2[0], z010, r_sub[0]);
  and a21 (t2[1], z010, r_sub[1]);
  and a22 (t2[2], z010, r_sub[2]);
  and a23 (t2[3], z010, r_sub[3]);

  and a30 (t3[0], z011, r_inv[0]);
  and a31 (t3[1], z011, r_inv[1]);
  and a32 (t3[2], z011, r_inv[2]);
  and a33 (t3[3], z011, r_inv[3]);

  and a40 (t4[0], z100, r_shl[0]);
  and a41 (t4[1], z100, r_shl[1]);
  and a42 (t4[2], z100, r_shl[2]);
  and a43 (t4[3], z100, r_shl[3]);
  and a50 (t5[0], z101, r_shr[0]);
  and a51 (t5[1], z101, r_shr[1]);
  and a52 (t5[2], z101, r_shr[2]);
  and a53 (t5[3], z101, r_shr[3]);

  or o0 (R[0], t0[0], t1[0], t2[0], t3[0], t4[0], t5[0]);
  or o1 (R[1], t0[1], t1[1], t2[1], t3[1], t4[1], t5[1]);
  or o2 (R[2], t0[2], t1[2], t2[2], t3[2], t4[2], t5[2]);
  or o3 (R[3], t0[3], t1[3], t2[3], t3[3], t4[3], t5[3]);

endmodule