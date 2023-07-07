module FourFuncCalc (KEY, SW, HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, CLOCK_50, LEDG);

input [17:0] SW;
input [3:0] KEY;
input CLOCK_50;

wire [36:0] CLKS_out; 

output [6:0] HEX7, HEX6, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
wire [6:0] HEX7w, HEX6w, HEX5w, HEX4w, HEX3w, HEX2w, HEX1w, HEX0w;

output [8:0]LEDG;
Clock_Div inst0(CLOCK_50, CLKS_out);

wire [11:0] Result; 


FourFuncCalc1 inst1 (.Clock(CLKS_out[22]), .Clear(SW[17] & ~KEY[0]), .Equals(SW[17] & ~KEY[3]), .Add(~SW[17] & ~KEY[3]), .Subtract(~SW[17] & ~KEY[2]), .Multiply(~SW[17] & ~KEY[1]), .Divide(~SW[17] & ~KEY[0]), .Number(SW[10:0]), .Result(Result), .Overflow(LEDG[8]));

wire TooLarge;
wire TooLarge1;


 Binary_to_7SEG inst2 (.N(SW[10:0]), .Encoding(1'b0), .Sign(HEX7w), .D2(HEX6w), .D1(HEX5w), .D0(HEX4w), .TooLarge(TooLarge));
 
 
 assign HEX7 = TooLarge? 7'b0111111: HEX7w;
 assign HEX6 = TooLarge? 7'b0111111: HEX6w;
 assign HEX5 = TooLarge? 7'b0111111: HEX5w;
 assign HEX4 = TooLarge? 7'b0111111: HEX4w;

 Binary_to_7SEG inst3 (.N(Result), .Encoding(1'b1), .Sign(HEX3w), .D2(HEX2w), .D1(HEX1w), .D0(HEX0w), .TooLarge(TooLarge1));
 assign HEX3 = TooLarge1? 7'b0111111: HEX3w;
 assign HEX2 = TooLarge1? 7'b0111111: HEX2w;
 assign HEX1 = TooLarge1? 7'b0111111: HEX1w;
 assign HEX0 = TooLarge1? 7'b0111111: HEX0w;

 
endmodule