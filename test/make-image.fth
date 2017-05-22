require search.fth

1 constant t-little-endian
cell constant t-cell

vocabulary image
only forth also image definitions
include lib/image.fth
include forth/asm.fth

target-image also assembler

\ Macros to signal failure or success using undefined opcodes.
: fail,   238 c, ;
: success,   255 c, ;

\ Let's start off with something simple.
nop,

\ Next, check that jumping ahead works.
ahead, fail, then,

\ A subroutine call and return.
ahead, label subroutine exit, then,
subroutine call, 0insn

\ Addition.
1 lit, -1 lit, +, if, fail, then,

\ Logic.
-1 lit, -1 lit, nand, if, fail, then,

\ Return stack.
1 lit, 2 lit,
>r, -1 lit, +, if, fail, then,
r>, -2 lit, +, if, fail, then,

\ Load and store.
1 lit, 4000 lit, !,
-1 lit, 4000 lit, @,
+, if, fail, then,

\ Jumping backwards
-1 lit, begin, 1 lit, +, until,

success,

save-target
