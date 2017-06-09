`include "verilog/cpu.v"

module top (input i_Clk, output o_LED_1);

  cpu cpu(i_Clk, o_LED_1);

endmodule
