# MIPS-Simulator
Mini-Simulator for MIPS Assemble Language

Open your Terminal and run these commands.

Write the LEX code in this file
```sh
$ vi mips_sim.l
```
Run mips.l through LEX to generate lex.yy.c
```sh
$ lex mips.l
```
Compile lex.yy.c to generate a.out
```sh
$ cc lex.yy.c
```
Input the input.asm file to a.out to generate the tokens
```sh
$ a.out < input.asm
```
