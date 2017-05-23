`include "verilog/cpu.v"
`timescale 1ns / 1ps

module cpu_tb();

   reg clock;

   initial
     begin
	clock = 1;
	$dumpfile("test.vcd");
	$dumpvars;
     end

   always
     begin
	#50 clock <= ~clock;
     end

   cpu nybble (clock);

endmodule
