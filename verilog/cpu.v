`timescale 1ns / 1ps

module cpu (clock);

   input clock;
   wire clock;

   // Memories.
   reg [15:0] dstack[0:15];	// Data stack.
   reg [15:0] rstack[0:15];	// Return stack.
   reg [7:0] memory[0:4095];	// Main memory.

   // Internal registers.
   reg [15:0] P = 0;		// Program pointer.
   reg [7:0] I = 0;		// Instruction.
   reg [3:0] S = 15;		// Data stack pointer.
   reg [3:0] R = 15;		// Return stack pointer.
   reg state = 0;

   // Frequently used instruction inputs.
   wire [15:0] T;		// Top of data stack.
   wire [15:0] N;		// Next item on data stack.
   wire [15:0] RT;		// Top of return stack.
   wire [15:0] MT;		// Memory word at address T.
   wire [15:0] MP;		// Memory word at address P.

   assign T = dstack[S];
   assign N = dstack[S+1];
   assign RT = rstack[R];
   assign MT = { memory[T+1], memory[T] };
   assign MP = { memory[P+1], memory[P] };

   initial
     begin
	$readmemh ("image.hex", memory);
	$dumpvars;
     end

   task undefined;
      begin
	 $write("undefined ");
	 $display("\nHALTED");
	 $finish;
      end
   endtask

   task trace;
      begin
	 case (I[7:4])
	   0: $write("noop ");		// Do nothing.
	   1: $write("call ");		// Subroutine call.
	   2: $write("exit ");		// Subroutine return.
	   3: $write("0branch ");	// Branch if zero.
	   4: $write("! ");		// Store word.
	   5: $write("@ ");		// Load word.
	   6: $write("c! ");		// Store byte.
	   7: $write("c@ ");		// Load byte.
	   8: $write("(literal) ");	// Immediate.
	   9: $write("+ ");		// Addition.
	   10: $write("nand ");		// Negative conjunction.
	   11: $write(">r ");		// Push to return stack.
	   12: $write("r> ");		// Pop from return stack.
	   13, 14, 15: undefined;
	 endcase
      end
   endtask

   // Fetch instruction.
   always @ (posedge clock)
     begin
	if (state == 0)
	  begin
	     I = memory[P];
	     $write("\n%04x %02x ", P, I);
	     P = P + 1;
	  end
	else
	  I = I << 4;
     end
	
   // Execute instruction.
   always @ (posedge clock)
     begin
	trace;

	case (I[7:4])
	  1: rstack[R-1] <= P + 2;		// call
	  4: { memory[T+1], memory[T] } <= N;	// !
	  5: dstack[S] <= MT;			// @
	  6: memory[T] <= N;			// c!
	  7: dstack[S] <= memory[T];		// c@
	  8: dstack[S-1] <= MP;			// (literal)
	  9: dstack[S+1] <= T + N;		// +
	  10: dstack[S+1] <= T ~& N;		// nand
	  11: rstack[R-1] <= T;			// >r
	  12: dstack[S-1] <= RT;		// r>
	endcase

	// Update P.
	case (I[7:4])
	  1: P <= MP;				// call
	  2: P <= RT;				// exit
	  3: if (T == 0)			// 0branch
	       P <= P + 1 + { {8{memory[P][7]}}, memory[P] };
	     else 
	       P <= P + 1;
	  8: P <= P + 2;			// (literal)
	endcase

	// Update S.
	case (I[7:4])
	  3, 9, 10, 11: S <= S + 1;		// 0branch, +, nand, >r
	  4, 6:		S <= S + 2;		// !, c!
	  8, 12:	S <= S - 1;		// (literal), r>
	endcase

	// Update R.
	case (I[7:4])
	  1, 11:	R <= R - 1;		// call, >r
	  2, 12:	R <= R + 1;		// exit, r>
	endcase

	// Update state.
	state <= ~state;
     end

endmodule
