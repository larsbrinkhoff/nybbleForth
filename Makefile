all: image check

image: test/make-image.fth asm.fth
	echo include $< | forth

check: test-asm test-cpu test-verilog

test-cpu: image nybble.fth
	echo include nybble.fth  load $<  hex start | forth > $@
	grep "FF undefined" $@

test-asm: test/test-asm.fth asm.fth
	echo include $< | forth > $@
	grep "Assembler test: PASS" $@

nybble: verilog/cpu.v
	iverilog -o $@ $^

image.hex: image
	hexdump -ve '1/1 "%02x "' < $< > $@

bench: test/cpu_tb.v verilog/cpu.v image.hex
	iverilog -Wall -o $@ $<

test-verilog: bench
	vvp $< > $@
	grep "ff undefined" $@

clean:
	rm -f *.hex *.vcd test-* image nybble bench
