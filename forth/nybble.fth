(* nybbleForth - Copyrght 2017 Lars Brinkhoff
Simulator for a Forth virtual machine with 4-bit instructions. *)

4096 constant msize   \ Memory size.
32 constant rsize     \ Return stack size.
2 constant csize      \ Cell size.

\ Allocate memory and load into it.
create memory  msize allot
: >target   memory + ;
: ?error   abort" Load error" ;
: read   memory msize rot read-file ?error drop ;
: load   parse-name r/o open-file ?error read ;

\ Allocate return stack and clear the stack pointer.
create rstack  rsize allot
variable rp
: @rp   rp @ ;
: 0rp   rstack rsize + rp ! ;

\ Fetch from instruction pointer, and clear it.
variable ip
: fetch   ip @ >target c@   1 ip +! ;
: >hi   8 lshift + ;
: 2fetch   fetch fetch >hi ;
: 0ip   0 ip ! ;

: nf-cells   csize * ;
: nf-mask   65535 and ;
: ext   dup 128 and if -256 or then ;

\ Instructions.
: nf->r   csize negate rp +!  @rp ! ;
: nf-r>   @rp @  csize rp +! ;
: nf-noop ;
: nf-call   2fetch  ip @ nf->r  ip ! ;
: nf-exit   nf-r> ip ! ;
: nf-0branch   fetch swap 0= if ext ip +! else drop then ;
: nf-c!   >target c! ;
: nf-c@   >target c@ ;
: nf-!   >target  over 8 lshift over 1+ c!  c! ;
: nf-@   dup nf-c@  swap 1+ nf-c@ >hi ;
: nf-(literal)   2fetch ;
: nf-+   + nf-mask ;
: nf-nand   nand nf-mask ;
: nf-undefined   cr ." HALTED" cr quit ;

\ Instruction dispatch table.
create instructions
  ' nf-noop ,
  ' nf-call ,
  ' nf-exit ,
  ' nf-0branch ,
  ' nf-! ,
  ' nf-@ ,
  ' nf-c! ,
  ' nf-c@ ,
  ' nf-(literal) ,
  ' nf-+ ,
  ' nf-nand ,
  ' nf->r ,
  ' nf-r> ,
  ' nf-undefined ,
  ' nf-undefined ,
  ' nf-undefined ,

\ Start virtual machine.  Decode loop.
: .ip   cr ip @ . ;
: trace   dup >name 3 /string type space ;
: step   cells instructions + @ trace execute ;
: run   begin .ip fetch dup . dup >r 4 rshift step  r> 15 and step again ;
: start   0ip 0rp run ;
