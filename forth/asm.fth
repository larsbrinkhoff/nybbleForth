\ Copyright 2017 Lars Brinkhoff

\ Assembler for nybbleForth.

\ Adds to FORTH vocabulary: ASSEMBLER CODE ;CODE.
\ Creates ASSEMBLER vocabulary with: END-CODE and nybbleForth opcodes.

\ This will become a cross assembler if loaded with a cross-compiling
\ vocabulary at the top of the search order.

require search.fth
also forth definitions
require lib/common.fth

vocabulary assembler

base @  hex

\ Assembler state.
variable opcode
variable data   defer ?data,
defer ?+data
defer insn,

\ Set opcode.
: opcode!   3@ drop >r opcode ! ;

\ Access instruction fields.
: opcode@   opcode @ ;
: data@   data @ ;
: +data   1 data +! ;

variable 'insn
: insn!   'insn ! ;
: insn@   'insn @ ;
: insn<>   insn@ <> ;

\ Possibly use a cross-compiling vocabulary to access a target image.
previous

\ Write opcode to either nybble.
0 value '0X
: !insn   is insn,  here insn! ;
: !0X   '0X !insn ;
: X0,   4 lshift c,  !0X ;
: !X0   ['] X0, !insn ;
: X0?   here insn<> drop 0 ;
: 0X,   X0? if X0, else ?+data insn@ 1- c+! !X0 then ;
also forth ' 0X, previous to '0X

\ Write instruction fields to memory.
: opcode,   opcode@ insn, ;
: w,   dup c,  8 rshift c, ;
: data8,   data@ c, ;
: data16,   data@ w, ;
: pc-   here - 2 -  ['] +data is ?+data ;

also forth

\ Set operand data.
: !data8   data !  ['] data8, is ?data, ;
: !data16   data !  ['] data16, is ?data, ;

\ Implements addressing modes.
: absolute   !data16 ;
: relative   pc- !data8 ;

\ Reset assembler state.
: 0insn   !X0 ;
: 0data   ['] noop is ?data,  ['] noop is ?+data ;
: 0asm   0data ;

\ Define instruction formats.
: instruction,   opcode! opcode, ?data, 0asm ;
: mnemonic ( u a "name" -- ) create ['] noop 3,  does> instruction, ;
: format:   create ] !csp  does> mnemonic ;
: immediate:   ' latestxt >body ! ;

\ Instruction formats.
format: 0op ;
format: branch   relative ;
format: imm   absolute ;

\ Instruction mnemonics.
previous also assembler definitions
00 0op nop,
01 0op @,
02 imm call,
03 0op exit,
04 imm lit,
07 0op r>,
08 0op +,
09 0op nand,
0A 0op >r,
0B branch 0branch,
0C 0op !,

\ Resolve jumps.
: >mark   here ;
: >resolve   here over - swap 1- c! ;

\ Unconditional jumps.
: label   here >r get-current ['] assembler set-current r> constant set-current ;
: begin,   0insn here ;
: again,   0 lit, 0branch, ;
: ahead,   0 again, >mark ;
: then,   0insn >resolve ;

\ Conditional jumps.
: if,   0 0branch, >mark 0insn ;
: until,   0branch, ;

: else,   ahead, swap then, ;
: while,   swap if, ;
: repeat,   again, then, ;

\ Runtime for ;CODE.  CODE! is defined elsewhere.
: (;code)   r> code! ;

\ Enter and exit assembler mode.
: start-code   also assembler 0asm 0insn ;
: end-code     align previous ;

also forth base ! previous

previous definitions also assembler

\ Standard assembler entry points.
: code    parse-name header, ?code, reveal start-code  ;
: ;code   postpone (;code) reveal postpone [ ?csp start-code ; immediate

0asm 0insn
previous
