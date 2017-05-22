\ Kernel for nybbleForth.  Copyright 2017 Lars Brinkhoff.

\ The compiler implements control flow and literals.  Everything else
\ must be built from these primitives: ! @ + nand >r r>

variable  temp
: drop    temp ! ;
: 2drop   + drop ;

: swap   >r temp ! r> temp @ ;
: over   >r temp ! temp @ r> temp @ ;
: rot    >r swap r> swap ;

: r@   r> temp ! temp @ >r temp @ ;
: 2>r   r> swap rot >r >r >r ;
: 2r>   r> r> r> rot >r swap ;

: dup    temp ! temp @ temp @ ;
: 2dup   over over ;
: ?dup   temp ! temp @ if temp @ temp @ then ;

: nip    >r temp ! r> ;

: invert   -1 nand ;
: negate   invert 1 + ;
: -        negate + ;

: 1+   1 + ;
: 1-   -1 + ;
: +!   dup >r @ + r> ! ;
: 0=   if 0 else -1 then ;
: =    - 0= ;
: <>   = 0= ;

: execute   >r ;

: 0<   [ 1 cell 8 * 1 - lshift ] literal nand invert if -1 else 0 then ;
: or   invert swap invert nand ;
: xor   2dup nand 1+ dup + + + ;
: and   nand invert ;
: 2*    dup + ;

: <   2dup xor 0< if drop 0< else - 0< then ;
: u<   2dup xor 0< if nip 0< else - 0< then ;
: >   swap < ;
: u>   swap u> ;

: c@   @ 255 and ;
: c!   dup >r @ 65280 and + r> ! ;
