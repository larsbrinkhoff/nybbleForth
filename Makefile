all: check

check: test-asm

test-asm: test/test-asm.fth asm.fth
	echo include $< | forth > $@
	grep "Assembler test: PASS" $@
