`timescale 1ns / 1ps

module cpu (clock);

   input clock;
   wire  clock;
   
   reg [15:0] dstack[0:15];
   reg [15:0] rstack[0:15];
   reg [7:0] memory[0:4095];

   reg [15:0] p = 0;
   reg [7:0] i = 0;
   reg [3:0] s = 15;
   reg [3:0] r = 15;

   task noop;
      $write("noop ");
   endtask

   task call;
      begin
	 $write("call ");
	 r = r - 1;
	 rstack[r] = p + 2;
	 p = { memory[p+1], memory[p] };
      end
   endtask

   task exit;
      begin
	 $write("exit ");
	 p = rstack[r];
	 r = r + 1;
      end
   endtask

   task zbranch;
      begin
	 $write("0branch ");
	 if (dstack[s] == 0)
	   p = p + 1 + { {8{memory[p][7]}}, memory[p] };
	 else 
	   p = p + 1;
	 s = s + 1;
      end
   endtask

   task store;
      begin
	 $write("! ");
	 { memory[dstack[s]+1], memory[dstack[s]] } = dstack[s+1];
	 s = s + 2;
      end
   endtask

   task fetch;
      begin
	 $write("@ ");
	 dstack[s] = { memory[dstack[s]+1], memory[dstack[s]] };
      end
   endtask

   task cstore;
      begin
	 $write("c! ");
	 memory[dstack[s]] = dstack[s+1];
	 s = s + 2;
      end
   endtask

   task cfetch;
      begin
	 $write("c@ ");
	 dstack[s] = memory[dstack[s]];
      end
   endtask

   task literal;
      begin
	 $write("(literal) ");
	 s = s - 1;
	 dstack[s] = { memory[p+1], memory[p] };
	 p = p + 2;
      end
   endtask

   task plus;
      begin
	 $write("+ ");
	 s = s + 1;
	 dstack[s] = dstack[s] + dstack[s - 1];
      end
   endtask

   task mynand;
      begin
	 $write("nand ");
	 s = s + 1;
	 dstack[s] = dstack[s] ~& dstack[s - 1];
      end
   endtask

   task tor;
      begin
	 $write(">r ");
	 r = r - 1;
	 rstack[r] = dstack[s];
	 s = s + 1;
      end
   endtask

   task rfrom;
      begin
	 $write("r> ");
	 s = s - 1;
	 dstack[r] = rstack[s];
	 r = r + 1;
      end
   endtask

   task undefined;
      begin
	 $write("undefined ");
	 $display("\nHALTED");
	 $finish;
      end
   endtask

   task execute;
      begin
	case (i >> 4)
	  0: noop;
	  1: call;
	  2: exit;
	  3: zbranch;
	  4: store;
	  5: fetch;
	  6: cstore;
	  7: cfetch;
	  8: literal;
	  9: plus;
	  10: mynand;
	  11: tor;
	  12: rfrom;
	  default: undefined;
	endcase
      end
   endtask
    
   initial
     begin
	$readmemh ("image.hex", memory);
	$dumpvars;
     end

   always @ (posedge clock)
     begin
	i = memory[p];
	$write("%04x %02x ", p, i);
	p = p + 1;
	execute;
	i = i << 4;
	execute;
	$write("\n");
     end
   
endmodule
