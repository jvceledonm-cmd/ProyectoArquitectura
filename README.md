# Calculadora de 4 bits en FPGA

Proyecto 1 del curso Arquitectura de Computadores, desarrollado en
Verilog para la FPGA Lattice iCE40 HX1K de la Nandland Go Board.

## Integrantes

- Nombre integrante 1: Juan Vicente Celedón
- Nombre integrante 2: Ignacio Cruzat
- Nombre integrante 3: Wille Saarenpaa

## Objetivo

Diseñar una calculadora de 4 bits utilizando lógica estructural,
compuertas básicas, registros y simulación digital.

## Operaciones implementadas

| Código | Operación |
|-------:|-----------|
| 000 | Reinicio |
| 001 | Suma A + B |
| 010 | Resta A - B |
| 011 | Resta inversa B - A |
| 100 | Shift left |
| 101 | Shift right |

Los números se representan en complemento a dos. Todos los resultados
se almacenan utilizando solamente 4 bits.

## Estructura del proyecto

- `calculadora_4bits.v`: integración del núcleo de la calculadora.
- `alu4.v`: selección de las operaciones.
- `adder4.v`: sumador de 4 bits.
- `full_adder.v`: sumador completo de 1 bit; bloque base de `adder4.v`.
- `invert4.v`: inversor bit a bit de 4 bits; utilizado para complemento a dos en `resta4.v`.
- `reset4.v`: genera `4'b0000` para la operación de reinicio `000`.
- `resta4.v`: resta A - B.
- `resta_inv4.v`: resta B - A.
- `shift_left4.v`: desplazamiento hacia la izquierda.
- `shift_right4.v`: desplazamiento hacia la derecha.
- `mux2_1.v`: multiplexor de dos entradas.
- `mux4_1.v`: multiplexor de cuatro entradas.
- `reg4.v`: registro del resultado.
- `calculadora_4bits_tb_basico.sv`: testbench principal.


## Simulación

La simulación utiliza Icarus Verilog y GTKWave, incluidos en OSS CAD Suite.

Cada vez que uno de los 3 integrantes abra el terminal poner lo siguiente:

set "PATH=RUTA\oss-cad-suite\bin;RUTA\oss-cad-suite\lib;%PATH%"

RUTA = carpeta donde cada uno descomprimió OSS CAD Suite.

Comprobar: iverilog -v

### Compilar

```bash
iverilog -g2012 -o tb_oficial.vvp calculadora_4bits_tb_basico.sv calculadora_4bits.v alu4.v reg4.v mux2_1.v reset4.v adder4.v full_adder.v resta4.v resta_inv4.v invert4.v shift_left4.v shift_right4.v mux4_1.v
```

### Ejecutar

```bash
vvp tb_oficial.vvp
```

### Abrir GTKWave

En el terminal del vscode de nuestro proyecto, escribir lo siguiente para abrir el GTKwave:

```bash

gtkwave calculadora_4bits_tb_basico.vcd


### Abrir las señales

```bash
gtkwave calculadora_4bits_tb_basico.vcd
```
