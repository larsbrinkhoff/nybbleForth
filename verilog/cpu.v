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

   always @*
     case (opcode)
       1: 	result = P + 2;		// call
       4: 	result = N;		// !
       5: 	result = MT;		// @
       6: 	result = MP;		// (literal)
       7: 	result = T + N;		// +
       8: 	result = T ~& N;	// nand
       9: 	result = T;		// >r
       10:	result = RT;		// r>
       default: result = 16'bx;
     endcase

   always @*
     case (opcode)
       3, 7, 8, 9: next_S = S + 1;	// 0branch, +, nand, >r
       4:	   next_S = S + 2;	// !
       6, 10:	   next_S = S - 1;	// (literal), r>
       default:    next_S = S;
     endcase

   always @*
     case (opcode)
       1, 9:	next_R = R - 1;		// call, >r
       2, 10:	next_R = R + 1;		// exit, r>
       default: next_R = R;
     endcase

   always @*
     casez (state_opcode)
       5'b0????: next_P = P + 1;
       5'b10001: next_P = MP;		// call
       5'b10010: next_P = RT;		// exit
       5'b10011: if (T == 0)		// 0branch
	            #10 next_P = P + 1 + { {8{memory[P][7]}}, memory[P] };
                  else 
	            next_P = P + 1;
       5'b10110: next_P = P + 2;	// (literal)
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
	  5'b10001, 5'b11001: rstack[R-1] <= result;	// call, >r
	  5'b10100: { memory[T+1], memory[T] } <= result;// !
	  5'b10101: dstack[S] <= result;		// @
	  5'b10110, 5'b11010: dstack[S-1] <= result;	// (literal), r>
	  5'b10111, 5'b11000: dstack[S+1] <= result;	// +, nand
	endcase
     end

endmodule
