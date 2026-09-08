module top_go_board (
    input  i_Clk,
    input  i_Switch_1,
    input  i_Switch_2,
    input  i_Switch_3,
    input  i_Switch_4,

    output o_LED_1,
    output o_LED_2,
    output o_LED_3,
    output o_LED_4,

    output o_Segment1_A,
    output o_Segment1_B,
    output o_Segment1_C,
    output o_Segment1_D,
    output o_Segment1_E,
    output o_Segment1_F,
    output o_Segment1_G,

    output o_Segment2_A,
    output o_Segment2_B,
    output o_Segment2_C,
    output o_Segment2_D,
    output o_Segment2_E,
    output o_Segment2_F,
    output o_Segment2_G
);

    wire slow_clk;

    free_counter18 reloj_lento (
        .clk(i_Clk),
        .slow_clk(slow_clk)
    );

    wire btn_inc;
    wire btn_dec;
    wire btn_ok;
    wire btn_prev;

    button_pulse b1 (
        .main_clk(i_Clk),
        .slow_clk(slow_clk),
        .button(i_Switch_1),
        .pulse(btn_inc)
    );

    button_pulse b2 (
        .main_clk(i_Clk),
        .slow_clk(slow_clk),
        .button(i_Switch_2),
        .pulse(btn_dec)
    );

    button_pulse b3 (
        .main_clk(i_Clk),
        .slow_clk(slow_clk),
        .button(i_Switch_3),
        .pulse(btn_ok)
    );

    button_pulse b4 (
        .main_clk(i_Clk),
        .slow_clk(slow_clk),
        .button(i_Switch_4),
        .pulse(btn_prev)
    );


    // ============================================================
    // ESTADO
    // 00 operacion
    // 01 op1
    // 10 op2
    // 11 resultado
    // ============================================================

    wire state0;
    wire state1;

    wire n_state0;
    wire n_state1;

    wire state0_next;
    wire state1_next;

    not st_n0 (
        n_state0,
        state0
    );

    not st_n1 (
        n_state1,
        state1
    );

    buf st_d0 (
        state0_next,
        n_state0
    );

    xor st_d1 (
        state1_next,
        state1,
        state0
    );

    dff_en st_ff0 (
        .clk(i_Clk),
        .en(btn_ok),
        .d(state0_next),
        .q(state0)
    );

    dff_en st_ff1 (
        .clk(i_Clk),
        .en(btn_ok),
        .d(state1_next),
        .q(state1)
    );


    wire st_operacion;
    wire st_op1;
    wire st_op2;
    wire st_resultado;

    and st_dec0 (
        st_operacion,
        n_state1,
        n_state0
    );

    and st_dec1 (
        st_op1,
        n_state1,
        state0
    );

    and st_dec2 (
        st_op2,
        state1,
        n_state0
    );

    and st_dec3 (
        st_resultado,
        state1,
        state0
    );


    // ============================================================
    // BOTONES INC / DEC
    // ============================================================

    wire any_step;

    or step_or (
        any_step,
        btn_inc,
        btn_dec
    );


    // ============================================================
    // CODIGO DE OPERACION
    // ============================================================

    wire code0;
    wire code1;
    wire code2;

    wire code_inc0;
    wire code_inc1;
    wire code_inc2;

    wire code_dec0;
    wire code_dec1;
    wire code_dec2;

    wire code_sel0;
    wire code_sel1;
    wire code_sel2;

    wire code_data0;
    wire code_data1;
    wire code_data2;

    wire code_step_en;
    wire code_zero_en;
    wire code_en;


    code_step6 code_logic (
        .c2(code2),
        .c1(code1),
        .c0(code0),

        .inc2(code_inc2),
        .inc1(code_inc1),
        .inc0(code_inc0),

        .dec2(code_dec2),
        .dec1(code_dec1),
        .dec0(code_dec0)
    );


    mux1_gate code_mux0 (
        .d0(code_dec0),
        .d1(code_inc0),
        .sel(btn_inc),
        .y(code_sel0)
    );

    mux1_gate code_mux1 (
        .d0(code_dec1),
        .d1(code_inc1),
        .sel(btn_inc),
        .y(code_sel1)
    );

    mux1_gate code_mux2 (
        .d0(code_dec2),
        .d1(code_inc2),
        .sel(btn_inc),
        .y(code_sel2)
    );


    and code_step_gate (
        code_step_en,
        st_operacion,
        any_step
    );

    and code_zero_gate (
        code_zero_en,
        st_resultado,
        btn_ok
    );

    or code_enable_gate (
        code_en,
        code_step_en,
        code_zero_en
    );


    mux1_gate code_zero_mux0 (
        .d0(code_sel0),
        .d1(1'b0),
        .sel(code_zero_en),
        .y(code_data0)
    );

    mux1_gate code_zero_mux1 (
        .d0(code_sel1),
        .d1(1'b0),
        .sel(code_zero_en),
        .y(code_data1)
    );

    mux1_gate code_zero_mux2 (
        .d0(code_sel2),
        .d1(1'b0),
        .sel(code_zero_en),
        .y(code_data2)
    );


    dff_en code_ff0 (
        .clk(i_Clk),
        .en(code_en),
        .d(code_data0),
        .q(code0)
    );

    dff_en code_ff1 (
        .clk(i_Clk),
        .en(code_en),
        .d(code_data1),
        .q(code1)
    );

    dff_en code_ff2 (
        .clk(i_Clk),
        .en(code_en),
        .d(code_data2),
        .q(code2)
    );


    // ============================================================
    // OP1
    // ============================================================

    wire [3:0] op1_reg;
    wire [3:0] op1_inc;
    wire [3:0] op1_dec;
    wire [3:0] op1_sel;
    wire [3:0] op1_data;

    wire op1_step_en;
    wire op1_zero_en;
    wire op1_en;


    step4 op1_stepper (
        .x(op1_reg),
        .inc(op1_inc),
        .dec(op1_dec)
    );


    mux1_gate op1_sel0 (
        .d0(op1_dec[0]),
        .d1(op1_inc[0]),
        .sel(btn_inc),
        .y(op1_sel[0])
    );

    mux1_gate op1_sel1 (
        .d0(op1_dec[1]),
        .d1(op1_inc[1]),
        .sel(btn_inc),
        .y(op1_sel[1])
    );

    mux1_gate op1_sel2 (
        .d0(op1_dec[2]),
        .d1(op1_inc[2]),
        .sel(btn_inc),
        .y(op1_sel[2])
    );

    mux1_gate op1_sel3 (
        .d0(op1_dec[3]),
        .d1(op1_inc[3]),
        .sel(btn_inc),
        .y(op1_sel[3])
    );


    and op1_step_gate (
        op1_step_en,
        st_op1,
        any_step
    );

    and op1_zero_gate (
        op1_zero_en,
        st_operacion,
        btn_ok
    );

    or op1_enable_gate (
        op1_en,
        op1_step_en,
        op1_zero_en
    );


    mux1_gate op1_zero0 (
        .d0(op1_sel[0]),
        .d1(1'b0),
        .sel(op1_zero_en),
        .y(op1_data[0])
    );

    mux1_gate op1_zero1 (
        .d0(op1_sel[1]),
        .d1(1'b0),
        .sel(op1_zero_en),
        .y(op1_data[1])
    );

    mux1_gate op1_zero2 (
        .d0(op1_sel[2]),
        .d1(1'b0),
        .sel(op1_zero_en),
        .y(op1_data[2])
    );

    mux1_gate op1_zero3 (
        .d0(op1_sel[3]),
        .d1(1'b0),
        .sel(op1_zero_en),
        .y(op1_data[3])
    );


    dff_en op1_ff0 (
        .clk(i_Clk),
        .en(op1_en),
        .d(op1_data[0]),
        .q(op1_reg[0])
    );

    dff_en op1_ff1 (
        .clk(i_Clk),
        .en(op1_en),
        .d(op1_data[1]),
        .q(op1_reg[1])
    );

    dff_en op1_ff2 (
        .clk(i_Clk),
        .en(op1_en),
        .d(op1_data[2]),
        .q(op1_reg[2])
    );

    dff_en op1_ff3 (
        .clk(i_Clk),
        .en(op1_en),
        .d(op1_data[3]),
        .q(op1_reg[3])
    );


    // ============================================================
    // OP2
    // ============================================================

    wire [3:0] op2_reg;
    wire [3:0] op2_inc;
    wire [3:0] op2_dec;
    wire [3:0] op2_sel;
    wire [3:0] op2_data;

    wire op2_step_en;
    wire op2_zero_en;
    wire op2_en;


    step4 op2_stepper (
        .x(op2_reg),
        .inc(op2_inc),
        .dec(op2_dec)
    );


    mux1_gate op2_sel0 (
        .d0(op2_dec[0]),
        .d1(op2_inc[0]),
        .sel(btn_inc),
        .y(op2_sel[0])
    );

    mux1_gate op2_sel1 (
        .d0(op2_dec[1]),
        .d1(op2_inc[1]),
        .sel(btn_inc),
        .y(op2_sel[1])
    );

    mux1_gate op2_sel2 (
        .d0(op2_dec[2]),
        .d1(op2_inc[2]),
        .sel(btn_inc),
        .y(op2_sel[2])
    );

    mux1_gate op2_sel3 (
        .d0(op2_dec[3]),
        .d1(op2_inc[3]),
        .sel(btn_inc),
        .y(op2_sel[3])
    );


    and op2_step_gate (
        op2_step_en,
        st_op2,
        any_step
    );

    and op2_zero_gate (
        op2_zero_en,
        st_op1,
        btn_ok
    );

    or op2_enable_gate (
        op2_en,
        op2_step_en,
        op2_zero_en
    );


    mux1_gate op2_zero0 (
        .d0(op2_sel[0]),
        .d1(1'b0),
        .sel(op2_zero_en),
        .y(op2_data[0])
    );

    mux1_gate op2_zero1 (
        .d0(op2_sel[1]),
        .d1(1'b0),
        .sel(op2_zero_en),
        .y(op2_data[1])
    );

    mux1_gate op2_zero2 (
        .d0(op2_sel[2]),
        .d1(1'b0),
        .sel(op2_zero_en),
        .y(op2_data[2])
    );

    mux1_gate op2_zero3 (
        .d0(op2_sel[3]),
        .d1(1'b0),
        .sel(op2_zero_en),
        .y(op2_data[3])
    );


    dff_en op2_ff0 (
        .clk(i_Clk),
        .en(op2_en),
        .d(op2_data[0]),
        .q(op2_reg[0])
    );

    dff_en op2_ff1 (
        .clk(i_Clk),
        .en(op2_en),
        .d(op2_data[1]),
        .q(op2_reg[1])
    );

    dff_en op2_ff2 (
        .clk(i_Clk),
        .en(op2_en),
        .d(op2_data[2]),
        .q(op2_reg[2])
    );

    dff_en op2_ff3 (
        .clk(i_Clk),
        .en(op2_en),
        .d(op2_data[3]),
        .q(op2_reg[3])
    );


    // ============================================================
    // RESULTADO ANTERIOR COMO OP2
    // ============================================================

    wire sel_op2_reg;

    wire sel_prev_set;
    wire sel_manual_clear;
    wire sel_enter_clear;
    wire sel_finish_clear;

    wire sel_clear;
    wire sel_en;


    and prev_set_gate (
        sel_prev_set,
        st_op2,
        btn_prev
    );

    and manual_clear_gate (
        sel_manual_clear,
        st_op2,
        any_step
    );

    and enter_clear_gate (
        sel_enter_clear,
        st_op1,
        btn_ok
    );

    and finish_clear_gate (
        sel_finish_clear,
        st_resultado,
        btn_ok
    );

    or clear_sel_gate (
        sel_clear,
        sel_manual_clear,
        sel_enter_clear,
        sel_finish_clear
    );

    or sel_enable_gate (
        sel_en,
        sel_prev_set,
        sel_clear
    );


    dff_en sel_ff (
        .clk(i_Clk),
        .en(sel_en),
        .d(sel_prev_set),
        .q(sel_op2_reg)
    );


    // ============================================================
    // EJECUTAR
    // ============================================================

    wire ejecutar;

    and execute_gate (
        ejecutar,
        st_op2,
        btn_ok
    );


    // ============================================================
    // CALCULADORA
    // ============================================================

    wire [2:0] codigo;

    buf code_out0 (
        codigo[0],
        code0
    );

    buf code_out1 (
        codigo[1],
        code1
    );

    buf code_out2 (
        codigo[2],
        code2
    );


    wire [3:0] resultado;


    calculadora_4bits calculadora (
        .clk(i_Clk),
        .ejecutar(ejecutar),
        .codigo(codigo),
        .sel_op2(sel_op2_reg),
        .op1(op1_reg),
        .op2_ext(op2_reg),
        .resultado(resultado)
    );


    // ============================================================
    // LEDs
    // ============================================================

    buf led1_gate (
        o_LED_1,
        code2
    );

    buf led2_gate (
        o_LED_2,
        code1
    );

    buf led3_gate (
        o_LED_3,
        code0
    );

    buf led4_gate (
        o_LED_4,
        sel_op2_reg
    );


    // ============================================================
    // VALOR MOSTRADO
    // ============================================================

    wire [3:0] op2_view;

    mux1_gate view0 (
        .d0(op2_reg[0]),
        .d1(resultado[0]),
        .sel(sel_op2_reg),
        .y(op2_view[0])
    );

    mux1_gate view1 (
        .d0(op2_reg[1]),
        .d1(resultado[1]),
        .sel(sel_op2_reg),
        .y(op2_view[1])
    );

    mux1_gate view2 (
        .d0(op2_reg[2]),
        .d1(resultado[2]),
        .sel(sel_op2_reg),
        .y(op2_view[2])
    );

    mux1_gate view3 (
        .d0(op2_reg[3]),
        .d1(resultado[3]),
        .sel(sel_op2_reg),
        .y(op2_view[3])
    );


    wire mostrar_valor;

    or show_gate (
        mostrar_valor,
        state0,
        state1
    );


    wire [3:0] valor_display;

    wire d0_a;
    wire d0_b;
    wire d0_c;

    wire d1_a;
    wire d1_b;
    wire d1_c;

    wire d2_a;
    wire d2_b;
    wire d2_c;

    wire d3_a;
    wire d3_b;
    wire d3_c;


    and disp0a (
        d0_a,
        st_op1,
        op1_reg[0]
    );

    and disp0b (
        d0_b,
        st_op2,
        op2_view[0]
    );

    and disp0c (
        d0_c,
        st_resultado,
        resultado[0]
    );

    or disp0o (
        valor_display[0],
        d0_a,
        d0_b,
        d0_c
    );


    and disp1a (
        d1_a,
        st_op1,
        op1_reg[1]
    );

    and disp1b (
        d1_b,
        st_op2,
        op2_view[1]
    );

    and disp1c (
        d1_c,
        st_resultado,
        resultado[1]
    );

    or disp1o (
        valor_display[1],
        d1_a,
        d1_b,
        d1_c
    );


    and disp2a (
        d2_a,
        st_op1,
        op1_reg[2]
    );

    and disp2b (
        d2_b,
        st_op2,
        op2_view[2]
    );

    and disp2c (
        d2_c,
        st_resultado,
        resultado[2]
    );

    or disp2o (
        valor_display[2],
        d2_a,
        d2_b,
        d2_c
    );


    and disp3a (
        d3_a,
        st_op1,
        op1_reg[3]
    );

    and disp3b (
        d3_b,
        st_op2,
        op2_view[3]
    );

    and disp3c (
        d3_c,
        st_resultado,
        resultado[3]
    );

    or disp3o (
        valor_display[3],
        d3_a,
        d3_b,
        d3_c
    );


    // ============================================================
    // SIGNO Y MAGNITUD
    // ============================================================

    wire [3:0] valor_inv;
    wire [3:0] valor_comp2;
    wire carry_magnitud;
    wire [3:0] magnitud;


    invert4 display_inv (
        .in(valor_display),
        .out(valor_inv)
    );


    adder4 display_comp2 (
        .A(valor_inv),
        .B(4'b0000),
        .Cin(1'b1),
        .S(valor_comp2),
        .Cout(carry_magnitud)
    );


    mux1_gate mag0 (
        .d0(valor_display[0]),
        .d1(valor_comp2[0]),
        .sel(valor_display[3]),
        .y(magnitud[0])
    );

    mux1_gate mag1 (
        .d0(valor_display[1]),
        .d1(valor_comp2[1]),
        .sel(valor_display[3]),
        .y(magnitud[1])
    );

    mux1_gate mag2 (
        .d0(valor_display[2]),
        .d1(valor_comp2[2]),
        .sel(valor_display[3]),
        .y(magnitud[2])
    );

    mux1_gate mag3 (
        .d0(valor_display[3]),
        .d1(valor_comp2[3]),
        .sel(valor_display[3]),
        .y(magnitud[3])
    );


    // ============================================================
    // DISPLAY DE SIGNO
    // ============================================================

    wire signo_g;

    nand signo_gate (
        signo_g,
        mostrar_valor,
        valor_display[3]
    );


    buf sign_a (
        o_Segment1_A,
        1'b1
    );

    buf sign_b (
        o_Segment1_B,
        1'b1
    );

    buf sign_c (
        o_Segment1_C,
        1'b1
    );

    buf sign_d (
        o_Segment1_D,
        1'b1
    );

    buf sign_e (
        o_Segment1_E,
        1'b1
    );

    buf sign_f (
        o_Segment1_F,
        1'b1
    );

    buf sign_g (
        o_Segment1_G,
        signo_g
    );


    // ============================================================
    // DISPLAY HEX
    // ============================================================

    wire blank_hex;

    not blank_gate (
        blank_hex,
        mostrar_valor
    );


    hex_to_7seg_gates hex_display (
        .hex(magnitud),
        .blank(blank_hex),

        .segA(o_Segment2_A),
        .segB(o_Segment2_B),
        .segC(o_Segment2_C),
        .segD(o_Segment2_D),
        .segE(o_Segment2_E),
        .segF(o_Segment2_F),
        .segG(o_Segment2_G)
    );

endmodule


// ================================================================
// MUX 1 BIT
// ================================================================

module mux1_gate (
    input d0,
    input d1,
    input sel,
    output y
);

    wire nsel;
    wire a0;
    wire a1;

    not g0 (
        nsel,
        sel
    );

    and g1 (
        a0,
        d0,
        nsel
    );

    and g2 (
        a1,
        d1,
        sel
    );

    or g3 (
        y,
        a0,
        a1
    );

endmodule


// ================================================================
// INCREMENTO Y DECREMENTO DE 4 BITS
// ================================================================

module step4 (
    input  [3:0] x,
    output [3:0] inc,
    output [3:0] dec
);

    wire c1;
    wire c2;

    wire b1;
    wire b2;

    wire nx0;
    wire nx1;
    wire nx2;


    not inc0_gate (
        inc[0],
        x[0]
    );

    xor inc1_gate (
        inc[1],
        x[1],
        x[0]
    );

    and inc_c1_gate (
        c1,
        x[1],
        x[0]
    );

    xor inc2_gate (
        inc[2],
        x[2],
        c1
    );

    and inc_c2_gate (
        c2,
        x[2],
        c1
    );

    xor inc3_gate (
        inc[3],
        x[3],
        c2
    );


    not dec_n0_gate (
        nx0,
        x[0]
    );

    not dec0_gate (
        dec[0],
        x[0]
    );

    xor dec1_gate (
        dec[1],
        x[1],
        nx0
    );

    not dec_n1_gate (
        nx1,
        x[1]
    );

    and dec_b1_gate (
        b1,
        nx1,
        nx0
    );

    xor dec2_gate (
        dec[2],
        x[2],
        b1
    );

    not dec_n2_gate (
        nx2,
        x[2]
    );

    and dec_b2_gate (
        b2,
        nx2,
        b1
    );

    xor dec3_gate (
        dec[3],
        x[3],
        b2
    );

endmodule


// ================================================================
// SECUENCIA DE CODIGOS 000 A 101
// ================================================================

module code_step6 (
    input c2,
    input c1,
    input c0,

    output inc2,
    output inc1,
    output inc0,

    output dec2,
    output dec1,
    output dec0
);

    wire n2;
    wire n1;
    wire n0;

    wire d0;
    wire d1;
    wire d2;
    wire d3;
    wire d4;
    wire d5;


    not n2_gate (
        n2,
        c2
    );

    not n1_gate (
        n1,
        c1
    );

    not n0_gate (
        n0,
        c0
    );


    and d0_gate (
        d0,
        n2,
        n1,
        n0
    );

    and d1_gate (
        d1,
        n2,
        n1,
        c0
    );

    and d2_gate (
        d2,
        n2,
        c1,
        n0
    );

    and d3_gate (
        d3,
        n2,
        c1,
        c0
    );

    and d4_gate (
        d4,
        c2,
        n1,
        n0
    );

    and d5_gate (
        d5,
        c2,
        n1,
        c0
    );


    or inc0_gate (
        inc0,
        d0,
        d2,
        d4
    );

    or inc1_gate (
        inc1,
        d1,
        d2
    );

    or inc2_gate (
        inc2,
        d3,
        d4
    );


    or dec0_gate (
        dec0,
        d0,
        d2,
        d4
    );

    or dec1_gate (
        dec1,
        d3,
        d4
    );

    or dec2_gate (
        dec2,
        d0,
        d5
    );

endmodule


// ================================================================
// CONTADOR PARA RELOJ LENTO
// ================================================================

module free_counter18 (
    input clk,
    output slow_clk
);

    wire [17:0] q;
    wire [17:0] d;
    wire [16:0] carry;


    not bit0_next (
        d[0],
        q[0]
    );

    buf carry0_gate (
        carry[0],
        q[0]
    );


    xor bit1_next (d[1], q[1], carry[0]);
    and carry1_gate (carry[1], q[1], carry[0]);

    xor bit2_next (d[2], q[2], carry[1]);
    and carry2_gate (carry[2], q[2], carry[1]);

    xor bit3_next (d[3], q[3], carry[2]);
    and carry3_gate (carry[3], q[3], carry[2]);

    xor bit4_next (d[4], q[4], carry[3]);
    and carry4_gate (carry[4], q[4], carry[3]);

    xor bit5_next (d[5], q[5], carry[4]);
    and carry5_gate (carry[5], q[5], carry[4]);

    xor bit6_next (d[6], q[6], carry[5]);
    and carry6_gate (carry[6], q[6], carry[5]);

    xor bit7_next (d[7], q[7], carry[6]);
    and carry7_gate (carry[7], q[7], carry[6]);

    xor bit8_next (d[8], q[8], carry[7]);
    and carry8_gate (carry[8], q[8], carry[7]);

    xor bit9_next (d[9], q[9], carry[8]);
    and carry9_gate (carry[9], q[9], carry[8]);

    xor bit10_next (d[10], q[10], carry[9]);
    and carry10_gate (carry[10], q[10], carry[9]);

    xor bit11_next (d[11], q[11], carry[10]);
    and carry11_gate (carry[11], q[11], carry[10]);

    xor bit12_next (d[12], q[12], carry[11]);
    and carry12_gate (carry[12], q[12], carry[11]);

    xor bit13_next (d[13], q[13], carry[12]);
    and carry13_gate (carry[13], q[13], carry[12]);

    xor bit14_next (d[14], q[14], carry[13]);
    and carry14_gate (carry[14], q[14], carry[13]);

    xor bit15_next (d[15], q[15], carry[14]);
    and carry15_gate (carry[15], q[15], carry[14]);

    xor bit16_next (d[16], q[16], carry[15]);
    and carry16_gate (carry[16], q[16], carry[15]);

    xor bit17_next (
        d[17],
        q[17],
        carry[16]
    );


    dff_en cff0  (.clk(clk), .en(1'b1), .d(d[0]),  .q(q[0]));
    dff_en cff1  (.clk(clk), .en(1'b1), .d(d[1]),  .q(q[1]));
    dff_en cff2  (.clk(clk), .en(1'b1), .d(d[2]),  .q(q[2]));
    dff_en cff3  (.clk(clk), .en(1'b1), .d(d[3]),  .q(q[3]));
    dff_en cff4  (.clk(clk), .en(1'b1), .d(d[4]),  .q(q[4]));
    dff_en cff5  (.clk(clk), .en(1'b1), .d(d[5]),  .q(q[5]));
    dff_en cff6  (.clk(clk), .en(1'b1), .d(d[6]),  .q(q[6]));
    dff_en cff7  (.clk(clk), .en(1'b1), .d(d[7]),  .q(q[7]));
    dff_en cff8  (.clk(clk), .en(1'b1), .d(d[8]),  .q(q[8]));
    dff_en cff9  (.clk(clk), .en(1'b1), .d(d[9]),  .q(q[9]));
    dff_en cff10 (.clk(clk), .en(1'b1), .d(d[10]), .q(q[10]));
    dff_en cff11 (.clk(clk), .en(1'b1), .d(d[11]), .q(q[11]));
    dff_en cff12 (.clk(clk), .en(1'b1), .d(d[12]), .q(q[12]));
    dff_en cff13 (.clk(clk), .en(1'b1), .d(d[13]), .q(q[13]));
    dff_en cff14 (.clk(clk), .en(1'b1), .d(d[14]), .q(q[14]));
    dff_en cff15 (.clk(clk), .en(1'b1), .d(d[15]), .q(q[15]));
    dff_en cff16 (.clk(clk), .en(1'b1), .d(d[16]), .q(q[16]));
    dff_en cff17 (.clk(clk), .en(1'b1), .d(d[17]), .q(q[17]));


    buf slow_gate (
        slow_clk,
        q[17]
    );

endmodule


// ================================================================
// BOTON
// ================================================================

module button_pulse (
    input main_clk,
    input slow_clk,
    input button,
    output pulse
);

    wire s0;
    wire s1;
    wire s2;

    wire slow_edge;
    wire ns2;

    wire m0;
    wire m1;
    wire m2;
    wire nm2;


    dff_en sample0 (
        .clk(slow_clk),
        .en(1'b1),
        .d(button),
        .q(s0)
    );

    dff_en sample1 (
        .clk(slow_clk),
        .en(1'b1),
        .d(s0),
        .q(s1)
    );

    dff_en sample2 (
        .clk(slow_clk),
        .en(1'b1),
        .d(s1),
        .q(s2)
    );


    not sample_inv (
        ns2,
        s2
    );

    and sample_rise (
        slow_edge,
        s1,
        ns2
    );


    dff_en main0 (
        .clk(main_clk),
        .en(1'b1),
        .d(slow_edge),
        .q(m0)
    );

    dff_en main1 (
        .clk(main_clk),
        .en(1'b1),
        .d(m0),
        .q(m1)
    );

    dff_en main2 (
        .clk(main_clk),
        .en(1'b1),
        .d(m1),
        .q(m2)
    );


    not main_inv (
        nm2,
        m2
    );

    and main_rise (
        pulse,
        m1,
        nm2
    );

endmodule


// ================================================================
// DECODIFICADOR HEX A 7 SEGMENTOS
// ================================================================

module hex_to_7seg_gates (
    input [3:0] hex,
    input blank,

    output segA,
    output segB,
    output segC,
    output segD,
    output segE,
    output segF,
    output segG
);

    wire n3;
    wire n2;
    wire n1;
    wire n0;

    wire d0;
    wire d1;
    wire d2;
    wire d3;
    wire d4;
    wire d5;
    wire d6;
    wire d7;
    wire d8;
    wire d9;
    wire dA;
    wire dB;
    wire dC;
    wire dD;
    wire dE;
    wire dF;

    wire rawA;
    wire rawB;
    wire rawC;
    wire rawD;
    wire rawE;
    wire rawF;
    wire rawG;


    not h_n3 (
        n3,
        hex[3]
    );

    not h_n2 (
        n2,
        hex[2]
    );

    not h_n1 (
        n1,
        hex[1]
    );

    not h_n0 (
        n0,
        hex[0]
    );


    and h_d0 (d0, n3, n2, n1, n0);
    and h_d1 (d1, n3, n2, n1, hex[0]);
    and h_d2 (d2, n3, n2, hex[1], n0);
    and h_d3 (d3, n3, n2, hex[1], hex[0]);

    and h_d4 (d4, n3, hex[2], n1, n0);
    and h_d5 (d5, n3, hex[2], n1, hex[0]);
    and h_d6 (d6, n3, hex[2], hex[1], n0);
    and h_d7 (d7, n3, hex[2], hex[1], hex[0]);

    and h_d8 (d8, hex[3], n2, n1, n0);
    and h_d9 (d9, hex[3], n2, n1, hex[0]);
    and h_dA (dA, hex[3], n2, hex[1], n0);
    and h_dB (dB, hex[3], n2, hex[1], hex[0]);

    and h_dC (dC, hex[3], hex[2], n1, n0);
    and h_dD (dD, hex[3], hex[2], n1, hex[0]);
    and h_dE (dE, hex[3], hex[2], hex[1], n0);
    and h_dF (dF, hex[3], hex[2], hex[1], hex[0]);


    or h_a (
        rawA,
        d1,
        d4,
        dB,
        dD
    );

    or h_b (
        rawB,
        d5,
        d6,
        dB,
        dC,
        dE,
        dF
    );

    or h_c (
        rawC,
        d2,
        dC,
        dE,
        dF
    );

    or h_d (
        rawD,
        d1,
        d4,
        d7,
        dA,
        dF
    );

    or h_e (
        rawE,
        d1,
        d3,
        d4,
        d5,
        d7,
        d9
    );

    or h_f (
        rawF,
        d1,
        d2,
        d3,
        d7,
        dD
    );

    or h_g (
        rawG,
        d0,
        d1,
        d7,
        dC
    );


    or h_out_a (
        segA,
        rawA,
        blank
    );

    or h_out_b (
        segB,
        rawB,
        blank
    );

    or h_out_c (
        segC,
        rawC,
        blank
    );

    or h_out_d (
        segD,
        rawD,
        blank
    );

    or h_out_e (
        segE,
        rawE,
        blank
    );

    or h_out_f (
        segF,
        rawF,
        blank
    );

    or h_out_g (
        segG,
        rawG,
        blank
    );

endmodule