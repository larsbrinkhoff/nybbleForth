`timescale 1ns / 1ps

module ram (input clock, wen, ren,
	    input [15:0] waddr, raddr,
	    input [7:0] wdata,
	    output reg [7:0] rdata);

   reg [7:0] mem [0:4095];

   initial
     $readmemh ("image.hex", mem);

   always @(posedge clock)
     begin
	if (wen)
	  mem[waddr] <= wdata;
	if (ren)
	  rdata <= mem[raddr];
     end

endmodule
