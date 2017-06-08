module foo
  (input i_Clk,
   input i_Switch_1,
   input i_Switch_2,
   input i_Switch_3,
   input i_Switch_4,
   output o_Segment1_A,
   output o_Segment1_B,
   output o_Segment1_C,
   output o_Segment1_D,
   output o_Segment1_E,
   output o_Segment1_F,
   output o_Segment1_G,
   output o_Segment2_A,
   output o_Segment2_B,
   output o_Segment2_C,
   output o_Segment2_D,
   output o_Segment2_E,
   output o_Segment2_F,
   output o_Segment2_G,
   output o_LED_1,
   output o_LED_2,
   output o_LED_3,
   output o_LED_4);

   reg [21:0] delay = 0;
   reg [3:0] counter = 0;

   assign o_LED_1 = counter[0];
   assign o_LED_2 = counter[1];
   assign o_LED_3 = counter[2];
   assign o_LED_4 = counter[3];

   assign o_Segment1_A = ~(counter == 0);
   assign o_Segment1_B = ~(counter == 1);
   assign o_Segment1_C = ~(counter == 2);
   assign o_Segment1_D = ~(counter == 3);
   assign o_Segment1_E = ~(counter == 4);
   assign o_Segment1_F = ~(counter == 5);
   assign o_Segment1_G = ~(counter == 6);
   assign o_Segment2_A = ~(counter == 7);
   assign o_Segment2_B = ~(counter == 8);
   assign o_Segment2_C = ~(counter == 9);
   assign o_Segment2_D = ~(counter == 10);
   assign o_Segment2_E = ~(counter == 11);
   assign o_Segment2_F = ~(counter == 12);
   assign o_Segment2_G = ~(counter == 13);

   always @(posedge i_Clk)
     begin
	delay <= delay + 1;
	counter <= counter + (delay == 0);
     end

endmodule
