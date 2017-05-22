\ Copyright 2017 Lars Brinkhoff.

: h: : ;

1 constant t-little-endian
2 constant t-cell
include lib/meta.fth

only forth also meta definitions

include forth/asm.fth

also assembler
: header, ( a u -- ) 0insn here t-word ;
: comp,   call, 0insn ;
: t-num   lit, ;
: dovar,   here 3 + lit, exit, ;

also forth
' comp, is t-compile,
' t-num is t-literal

0 org

host also meta definitions

h: :   parse-name header, ] ;
h: create   parse-name header, dovar, ;
h: variable   create cell allot ;

only forth also meta also compiler definitions previous

also assembler
h: exit   exit, ;
h: !   !, ;
h: @   @, ;
h: +   +, ;
h: nand   nand, ;
h: >r   >r, ;
h: r>   r>, ;

h: if   if, ;
h: ahead   ahead, ;
h: then   then, ;
h: else   else, ;
h: begin   begin, ;
h: again   again, ;
h: until   until, ;
h: while   while, ;
h: repeat   repeat, ;
previous

h: ;   [compile] exit [compile] [ ;
h: [']   ' t-literal ;
h: [char]   char t-literal ;
h: literal   t-literal ;
h: compile   ' t-literal compile , ;
h: [compile]   ' , ;
h: does>   compile (does>) ;

2 t-constant cell

target

include forth/kernel.fth

only forth also meta also t-words resolve-all-forward-refs

only forth also meta save-target
