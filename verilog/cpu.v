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
   reg [1:0] state = 2;

   // Frequently used instruction inputs.
   wire [15:0] T;		// Top of data stack.
   wire [15:0] N;		// Next item on data stack.
   wire [15:0] RT;		// Top of return stack.
   wire [15:0] MT;		// Memory word at address T.
   wire [15:0] MP;		// Memory word at address P.

   wire [3:0] opcode;

   assign #5 T = dstack[S];
   assign #5 N = dstack[S+1];
   assign #5 RT = rstack[R];
   assign #20 MT = { memory[T+1], memory[T] };
   assign #20 MP = { memory[P+1], memory[P] };
   assign opcode = I[7:4];

   initial
     $readmemh ("image.hex", memory);

   task undefined;
      begin
	 $write("undefined ");
	 $display("\nHALTED");
	 $finish;
      end
   endtask

   task trace;
      begin
	 case (opcode)
	   0: $write("noop ");		// Do nothing.
	   1: $write("call ");		// Subroutine call.
	   2: $write("exit ");		// Subroutine return.
	   3: $write("0branch ");	// Branch if zero.
	   4: $write("! ");		// Store word.
	   5: $write("@ ");		// Load word.
	   6: $write("(literal) ");	// Immediate.
	   7: $write("+ ");		// Addition.
	   8: $write("nand ");		// Negative conjunction.
	   9: $write(">r ");		// Push to return stack.
	   10: $write("r> ");		// Pop from return stack.
	   default: undefined;
	 endcase
      end
   endtask

   always @ (posedge clock)
     begin
	// Update state.
	if (state == 2)
	  state <= 0;
	else
	  state <= state + 1;

	case (state)
	  0: { I, P } <= #10 { memory[P], P + 16'b1 };	// Fetch instruction.
	  1, 2:
	    begin
	       if (state == 1)
		 $write("\n%04x %02x ", P, I);
	       trace;

	       case (opcode)
		 1: #5 rstack[R-1] <= #1 P + 2;		// call
		 4: #20 { memory[T+1], memory[T] } <= N;// !
		 5: #5 dstack[S] <= MT;			// @
		 6: #5 dstack[S-1] <=  MP;		// (literal)
		 7: #5 dstack[S+1] <= #1 T + N;		// +
		 8: #5 dstack[S+1] <= #1 T ~& N;	// nand
		 9: #5 rstack[R-1] <= T;		// >r
		 10: #5 dstack[S-1] <= RT;		// r>
	       endcase

	       case (opcode)
		 1: P <= MP;			// call
		 2: P <= RT;			// exit
		 3: if (T == 0)			// 0branch
	              P <= #11 P + 1 + { {8{memory[P][7]}}, memory[P] };
		    else 
		      P <= #1 P + 1;
		 6: P <= #1 P + 2;		// (literal)
	       endcase

	       // Update S.
	       case (opcode)
		 3, 7, 8, 9:	S <= #1 S + 1;	// 0branch, +, nand, >r
		 4:		S <= #1 S + 2;	// !
		 6, 10:		S <= #1 S - 1;	// (literal), r>
	       endcase

	       // Update R.
	       case (opcode)
		 1, 9:		R <= #1 R - 1;	// call, >r
		 2, 10:		R <= #1 R + 1;	// exit, r>
	       endcase

	       I <= #1 I << 4;
	    end
	endcase
     end

endmodule
