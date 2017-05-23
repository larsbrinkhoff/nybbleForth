require forth/asm.fth

hex

: fail? ( c a -- a' f ) 1- tuck c@ <> ;
: .fail   cr ." FAIL: " source 5 - type cr ;
: ?fail   fail? if .fail abort then ;
: check   here begin depth 1- while ?fail repeat drop ;

.( Assembler test: )
code assembler-test

   nop, nop,                00 check
   nop, exit,               02 check
   exit, nop,               20 check
   !, @,                    45 check
   +, nand,                 78 check
   >r, r>,                  9A check

   0 call, nop,             10 00 00 check
   42 lit, nop,             60 42 00 check
   1234 lit, nop,           60 34 12 check
   here 0branch, nop,       30 FE check

   nop, 0 call,             01 00 00 check
   @, 0 lit,                56 00 00 check
   here +, 0branch,         73 FE check

   exit, 1 c, 0insn +, nand,      20 01 78 check
   exit, exit, 1 c, @, !,   22 01 54 check

   \ Unconditional jumps are coded as 0 lit, 0branch,
   begin, again,            63 00 00 FC check
   begin, +, again, nop,    76 00 00 30 FB check
   +, begin, again,         70 63 00 00 FC check
   ahead, then,             63 00 00 00 check
   ahead, +, then,          63 00 00 01 70 check
   +, ahead, then,          76 00 00 30 00 check
   if, then, 0insn          30 00 check
   if, +, then,             30 01 70 check
   +, if, +, then,          73 01 70 check
   begin, until,            30 FE check
   begin, +, until,         73 FE check
   +, begin, +, until,      70 73 FE check

   if, else, then,          30 04 63 00 00 00 check
   if, +, else, then,       30 05 76 00 00 30 00 check
   if, else, +, then,       30 04 63 00 00 01 70 check

end-code
.( PASS ) cr
