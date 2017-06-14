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
   reg [15:0] result, next_P;
   reg [3:0] next_S, next_R;
   reg [7:0] next_I;

   // Frequently used instruction inputs.
   wire [15:0] T;		// Top of data stack.
   wire [15:0] N;		// Next item on data stack.
   wire [15:0] RT;		// Top of return stack.
   wire [15:0] MT;		// Memory word at address T.
   wire [15:0] MP;		// Memory word at address P.

   wire [3:0] opcode;
   wire [4:0] state_opcode;

   assign #5 T = dstack[S];
   assign #5 N = dstack[S+1];
   assign #5 RT = rstack[R];
   assign #20 MT = { memory[T+1], memory[T] };
   assign #20 MP = { memory[P+1], memory[P] };
   assign opcode = I[7:4];
   assign state_opcode = { state != 0, opcode };

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
	   1: $write("@ ");		// Load word.
	   2: $write("call ");		// Subroutine call.
	   3: $write("exit ");		// Subroutine return.
	   4: $write("(literal) ");	// Immediate.
	   7: $write("r> ");		// Pop from return stack.
	   8: $write("+ ");		// Addition.
	   9: $write("nand ");		// Negative conjunction.
	   10: $write(">r ");		// Push to return stack.
	   11: $write("0branch ");	// Branch if zero.
	   12: $write("! ");		// Store word.
	   default: undefined;
	 endcase
      end
   endtask

   // This instruction set is laid out to simplify decoding.  The two
   // most significant bits directly encode the data stack pointer
   // effect.  The return stack pointer effect mostly comes from the
   // two least significant bits.  Some instructions have been placed
   // in particular locations to reduce logic.

   always @*
     case (opcode)
       1: 	result = MT;		// @
       2: 	result = P + 2;		// call
       4: 	result = MP;		// (literal)
       7:	result = RT;		// r>
       8: 	result = T + N;		// +
       9: 	result = T ~& N;	// nand
       10: 	result = T;		// >r
       12: 	result = N;		// !
       default: result = 16'bx;
     endcase

   always @*
     case (opcode[3:2])
       2'b00: next_S = S;		// noop, @, call, exit
       2'b01: next_S = S - 1;		// (literal), r>
       2'b10: next_S = S + 1;		// +, nand, >r, 0branch
       2'b11: next_S = S + 2;		// !
     endcase

   always @*
     casez (opcode)
       4'b??10: next_R = R - 1;		// call, >r
       4'b0?11: next_R = R + 1;		// exit, r>
       default: next_R = R;
     endcase

   always @*
     casez (state_opcode)
       5'b0????: next_P = P + 1;
       5'b10010: next_P = MP;		// call
       5'b10011: next_P = RT;		// exit
       5'b10100: next_P = P + 2;	// (literal)
       5'b11011: if (T == 0)		// 0branch
	            #10 next_P = P + 1 + { {8{memory[P][7]}}, memory[P] };
                  else 
	            next_P = P + 1;
       default:  next_P = P;
     endcase

   always @*
     case (state)
       0:	#10 next_I = memory[P];
       1:	next_I = I << 4;
       default:	next_I = 8'bx;
     endcase

   always @ (posedge clock)
     begin
	if (state == 1)
	  $write("\n%04x %02x ", P, I);
	if (state != 0)
	  trace;

	state <= (state == 2 ? 0 : state + 1);
	P <= next_P;
	I <= next_I;
	S <= next_S;
	R <= next_R;

	casez (state_opcode)
	  5'b0????: ;
	  5'b10001: dstack[S] <= result;	// @
	  5'b101??: dstack[S-1] <= result;	// (literal), r>
	  5'b1100?: dstack[S+1] <= result;	// +, nand
	  5'b111??: { memory[T+1], memory[T] } <= result;// !
	  5'b1??10: rstack[R-1] <= result;	// call, >r
	endcase
     end

endmodule
