`include "verilog/cpu.v"
`include "verilog/ram.v"
`timescale 1ns / 1ps

module cpu_tb();

   reg clock;

   wire wen, ren;
   wire [15:0] waddr, raddr;
   wire [7:0]  wdata, rdata;

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

   ram memory (clock, wen, ren, waddr, raddr, wdata, rdata);
   cpu nybble (clock, wen, ren, waddr, raddr, wdata, rdata);

endmodule
