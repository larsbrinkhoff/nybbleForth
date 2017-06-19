`timescale 1ns / 1ps

module cpu (clock, out);

   input wire clock;
   output reg out = 0;

   reg [15:0] dstack[0:15];
   reg [15:0] rstack[0:15];
   reg [7:0] memory[0:1];

   reg [15:0] P = 0;
   reg [15:0] T = 0;
   reg [7:0] I = 0;
   reg [3:0] S = 15;
   reg [3:0] R = 15;

   initial
     $readmemh ("image.hex", memory);

   always @ (posedge clock)
     begin
	I <= memory[P];
	P <= P + 1;
	S <= S - 1;
	R <= R - 1;

	case (I)
	  1: T <= rstack[R];
	  2: T <= dstack[S];
	  3: T <= dstack[S+1];
	  4: out <= 1;
	  5: dstack[S-1] <= 0;
	  6: memory[T] <= 0;
	  7: rstack[R-1] <= 0;
	endcase
     end

endmodule
