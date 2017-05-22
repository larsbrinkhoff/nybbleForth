[![Build Status](https://travis-ci.org/larsbrinkhoff/nybbleForth.svg?branch=master)](https://travis-ci.org/larsbrinkhoff/nybbleForth)

Stack machine with 4-bit instructions.

There's a simulator, an assembler, a cross compiler, and a Forth
kernel, all written in Forth.  There's a hardware design written in
Verilog.

Internal registers

| Name | Size | Function
| ---- | ---- | ---
| P    |  16  | Program pointer
| I    |   8  | Instruction
| S    |   4  | Data stack pointer
| R    |   4  | Return stack pointer

The machine has 11 instructions, encoded two per byte.  Some have an 8
or 16-bit operand.

| Code | Name | Size | Operation
| ---- | ---- | ---- | ---------
|  0   | noop |    4 | No operation
|  1   | call | 4+16 | Push P to return stack, fetch a word and jump
|  2   | exit |    4  | Pop P from return stack
|  3   | 0branch | 4+8 | Fetch a byte and add to P if popped data stack is zero
|  4   | ! |       4 | Store word into memory
|  5   | @ |       4 | Load word from memory
|  6   | (literal) | 4+16 | Fetch a word and push to stack
|  7   | + |       4 | Add top two items on data stack
|  8   | nand |    4 | Inverted conjunction of the two top items on data stack
|  9   | >r |      4 | Pop data stack and push to return stack
| 10   | r> |      4 | Pop return stack and push to data stack

The word size is 16 bits, but this is easy to reconfigure.

Jump targets are always byte aligned, which makes it necessary to
sometimes pad instructions with noop.  The table lists unpadded sizes.

Instructions are always fetched 8 bits at a time.  Operands are
fetched after this.  If a jump instruction is executed first in an
8-bit word, it's undefined whether the second instruction is executed
or not.
