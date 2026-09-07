module calculadora_4bits (
  input  wire       clk,
  input  wire       ejecutar,
  input  wire [2:0] codigo,
  input  wire       sel_op2,
  input  wire [3:0] op1,
  input  wire [3:0] op2_ext,
  output wire [3:0] resultado
);

  wire [3:0] b_mux;
  wire [3:0] d_alu;

  mux2_1 mx0 (.d0(op2_ext[0]), .d1(resultado[0]), .s(sel_op2), .y(b_mux[0]));
  mux2_1 mx1 (.d0(op2_ext[1]), .d1(resultado[1]), .s(sel_op2), .y(b_mux[1]));
  mux2_1 mx2 (.d0(op2_ext[2]), .d1(resultado[2]), .s(sel_op2), .y(b_mux[2]));
  mux2_1 mx3 (.d0(op2_ext[3]), .d1(resultado[3]), .s(sel_op2), .y(b_mux[3]));

  alu4 alu (
    .A(op1),
    .B(b_mux),
    .codigo(codigo),
    .R(d_alu)
  );

  reg4 acc (
    .clk(clk),
    .en(ejecutar),
    .d(d_alu),
    .q(resultado)
  );

endmodule