require forth/asm.fth

hex

: fail? ( c a -- a' f ) 1- tuck c@ <> ;
: .fail   cr ." FAIL: " source 5 - type cr ;
: ?fail   fail? if .fail abort then ;
: check   here begin depth 1- while ?fail repeat drop ;

.( Assembler test: )
code assembler-test

   nop, nop,                00 check
   nop, exit,               03 check
   exit, nop,               30 check
   !, @,                    C1 check
   +, nand,                 89 check
   >r, r>,                  A7 check

   0 call, nop,             20 00 00 check
   42 lit, nop,             40 42 00 check
   1234 lit, nop,           40 34 12 check
   here 0branch, nop,       B0 FE check

   nop, 0 call,             02 00 00 check
   @, 0 lit,                14 00 00 check
   here +, 0branch,         8B FE check

   exit, 1 c, 0insn +, nand,      30 01 89 check
   exit, exit, 1 c, @, !,   33 01 1C check

   \ Unconditional jumps are coded as 0 lit, 0branch,
   begin, again,            4B 00 00 FC check
   begin, +, again, nop,    84 00 00 B0 FB check
   +, begin, again,         80 4B 00 00 FC check
   ahead, then,             4B 00 00 00 check
   ahead, +, then,          4B 00 00 01 80 check
   +, ahead, then,          84 00 00 B0 00 check
   if, then, 0insn          B0 00 check
   if, +, then,             B0 01 80 check
   +, if, +, then,          8B 01 80 check
   begin, until,            B0 FE check
   begin, +, until,         8B FE check
   +, begin, +, until,      80 8B FE check

   if, else, then,          B0 04 4B 00 00 00 check
   if, +, else, then,       B0 05 84 00 00 B0 00 check
   if, else, +, then,       B0 04 4B 00 00 01 80 check

end-code
.( PASS ) cr
