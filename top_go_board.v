module top_go_board (
    input  i_Clk,
    input  i_Switch_1,   // superior izquierdo: incrementar
    input  i_Switch_2,   // inferior izquierdo: disminuir
    input  i_Switch_3,   // superior derecho: confirmar
    input  i_Switch_4,   // inferior derecho: usar resultado anterior

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

    // ------------------------------------------------------------
    // BOTONES CON DEBOUNCE
    // ------------------------------------------------------------

    wire btn_inc;
    wire btn_dec;
    wire btn_ok;
    wire btn_prev;

    debounce_pulse db1 (
        .clk(i_Clk),
        .button(i_Switch_1),
        .pulse(btn_inc)
    );

    debounce_pulse db2 (
        .clk(i_Clk),
        .button(i_Switch_2),
        .pulse(btn_dec)
    );

    debounce_pulse db3 (
        .clk(i_Clk),
        .button(i_Switch_3),
        .pulse(btn_ok)
    );

    debounce_pulse db4 (
        .clk(i_Clk),
        .button(i_Switch_4),
        .pulse(btn_prev)
    );

    // ------------------------------------------------------------
    // ESTADOS
    // ------------------------------------------------------------

    localparam ST_OPERACION = 2'b00;
    localparam ST_OP1       = 2'b01;
    localparam ST_OP2       = 2'b10;
    localparam ST_RESULTADO = 2'b11;

    reg [1:0] estado = ST_OPERACION;

    reg [2:0] codigo_reg = 3'b000;
    reg [3:0] op1_reg = 4'b0000;
    reg [3:0] op2_reg = 4'b0000;

    reg sel_op2_reg = 1'b0;
    reg ejecutar_reg = 1'b0;

    wire [3:0] resultado;

    // ------------------------------------------------------------
    // CALCULADORA
    // ------------------------------------------------------------

    calculadora_4bits calculadora (
        .clk(i_Clk),
        .ejecutar(ejecutar_reg),
        .codigo(codigo_reg),
        .sel_op2(sel_op2_reg),
        .op1(op1_reg),
        .op2_ext(op2_reg),
        .resultado(resultado)
    );

    // ------------------------------------------------------------
    // MAQUINA DE ESTADOS
    // ------------------------------------------------------------

    always @(posedge i_Clk) begin

        ejecutar_reg <= 1'b0;

        case (estado)

            // ====================================================
            // SELECCION DE OPERACION
            // ====================================================

            ST_OPERACION: begin

                if (btn_inc) begin
                    if (codigo_reg == 3'b101)
                        codigo_reg <= 3'b000;
                    else
                        codigo_reg <= codigo_reg + 1'b1;
                end

                if (btn_dec) begin
                    if (codigo_reg == 3'b000)
                        codigo_reg <= 3'b101;
                    else
                        codigo_reg <= codigo_reg - 1'b1;
                end

                if (btn_ok) begin
                    op1_reg <= 4'b0000;
                    estado <= ST_OP1;
                end

            end

            // ====================================================
            // INGRESO OP1
            // ====================================================

            ST_OP1: begin

                if (btn_inc)
                    op1_reg <= op1_reg + 1'b1;

                if (btn_dec)
                    op1_reg <= op1_reg - 1'b1;

                if (btn_ok) begin
                    op2_reg <= 4'b0000;
                    sel_op2_reg <= 1'b0;
                    estado <= ST_OP2;
                end

            end

            // ====================================================
            // INGRESO OP2
            // ====================================================

            ST_OP2: begin

                if (btn_inc) begin
                    op2_reg <= op2_reg + 1'b1;
                    sel_op2_reg <= 1'b0;
                end

                if (btn_dec) begin
                    op2_reg <= op2_reg - 1'b1;
                    sel_op2_reg <= 1'b0;
                end

                // usar resultado anterior como segundo operando
                if (btn_prev)
                    sel_op2_reg <= 1'b1;

                if (btn_ok) begin
                    ejecutar_reg <= 1'b1;
                    estado <= ST_RESULTADO;
                end

            end

            // ====================================================
            // MOSTRAR RESULTADO
            // ====================================================

            ST_RESULTADO: begin

                if (btn_ok) begin
                    codigo_reg <= 3'b000;
                    sel_op2_reg <= 1'b0;
                    estado <= ST_OPERACION;
                end

            end

        endcase

    end

    // ------------------------------------------------------------
    // LEDs
    // ------------------------------------------------------------

    assign o_LED_1 = codigo_reg[2];
    assign o_LED_2 = codigo_reg[1];
    assign o_LED_3 = codigo_reg[0];

    // LED 4 indica uso del resultado anterior
    assign o_LED_4 = sel_op2_reg;

    // ------------------------------------------------------------
    // VALOR PARA DISPLAY
    // ------------------------------------------------------------

    reg [3:0] valor_display;
    reg mostrar_valor;

    always @(*) begin

        valor_display = 4'b0000;
        mostrar_valor = 1'b1;

        case (estado)

            ST_OPERACION: begin
                valor_display = 4'b0000;
                mostrar_valor = 1'b0;
            end

            ST_OP1: begin
                valor_display = op1_reg;
            end

            ST_OP2: begin

                if (sel_op2_reg)
                    valor_display = resultado;
                else
                    valor_display = op2_reg;

            end

            ST_RESULTADO: begin
                valor_display = resultado;
            end

        endcase

    end

    // ------------------------------------------------------------
    // SIGNO Y MAGNITUD
    // ------------------------------------------------------------

    wire valor_negativo;
    wire [3:0] magnitud;

    assign valor_negativo = valor_display[3];

    assign magnitud =
        valor_negativo
        ? ((~valor_display) + 1'b1)
        : valor_display;

    wire [6:0] segmentos_signo;
    wire [6:0] segmentos_hex;

    // Display 1:
    // apagado si positivo
    // "-" si negativo

    assign segmentos_signo =
        !mostrar_valor
        ? 7'b1111111
        : (
            valor_negativo
            ? 7'b1111110
            : 7'b1111111
          );

    // Display 2:
    // magnitud hexadecimal

    hex_to_7seg display_hex (
        .hex(magnitud),
        .blank(!mostrar_valor),
        .segments(segmentos_hex)
    );

    // ------------------------------------------------------------
    // DISPLAY 1
    // ------------------------------------------------------------

    assign o_Segment1_A = segmentos_signo[6];
    assign o_Segment1_B = segmentos_signo[5];
    assign o_Segment1_C = segmentos_signo[4];
    assign o_Segment1_D = segmentos_signo[3];
    assign o_Segment1_E = segmentos_signo[2];
    assign o_Segment1_F = segmentos_signo[1];
    assign o_Segment1_G = segmentos_signo[0];

    // ------------------------------------------------------------
    // DISPLAY 2
    // ------------------------------------------------------------

    assign o_Segment2_A = segmentos_hex[6];
    assign o_Segment2_B = segmentos_hex[5];
    assign o_Segment2_C = segmentos_hex[4];
    assign o_Segment2_D = segmentos_hex[3];
    assign o_Segment2_E = segmentos_hex[2];
    assign o_Segment2_F = segmentos_hex[1];
    assign o_Segment2_G = segmentos_hex[0];

endmodule


// ================================================================
// DEBOUNCE + PULSO
// ================================================================

module debounce_pulse (
    input clk,
    input button,
    output pulse
);

    reg sync0 = 1'b0;
    reg sync1 = 1'b0;

    reg stable = 1'b0;
    reg stable_d = 1'b0;

    reg [17:0] count = 18'b0;

    always @(posedge clk) begin

        sync0 <= button;
        sync1 <= sync0;

        if (sync1 == stable) begin

            count <= 18'b0;

        end
        else begin

            count <= count + 1'b1;

            if (&count) begin
                stable <= sync1;
                count <= 18'b0;
            end

        end

        stable_d <= stable;

    end

    assign pulse = stable & ~stable_d;

endmodule


// ================================================================
// HEX A DISPLAY 7 SEGMENTOS
// Activo en bajo
// orden: A B C D E F G
// ================================================================

module hex_to_7seg (
    input [3:0] hex,
    input blank,
    output reg [6:0] segments
);

    always @(*) begin

        if (blank) begin

            segments = 7'b1111111;

        end
        else begin

            case (hex)

                4'h0: segments = 7'b0000001;
                4'h1: segments = 7'b1001111;
                4'h2: segments = 7'b0010010;
                4'h3: segments = 7'b0000110;

                4'h4: segments = 7'b1001100;
                4'h5: segments = 7'b0100100;
                4'h6: segments = 7'b0100000;
                4'h7: segments = 7'b0001111;

                4'h8: segments = 7'b0000000;
                4'h9: segments = 7'b0000100;
                4'hA: segments = 7'b0001000;
                4'hB: segments = 7'b1100000;

                4'hC: segments = 7'b0110001;
                4'hD: segments = 7'b1000010;
                4'hE: segments = 7'b0110000;
                4'hF: segments = 7'b0111000;

            endcase

        end

    end

endmodule