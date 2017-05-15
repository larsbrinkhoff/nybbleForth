all: image check

image: test/make-image.fth asm.fth
	echo include $< | forth

check: test-asm test-cpu

test-cpu: image nybble.fth
	echo include nybble.fth  load $<  hex start | forth > $@
	grep "FF undefined" $@

test-asm: test/test-asm.fth asm.fth
	echo include $< | forth > $@
	grep "Assembler test: PASS" $@
