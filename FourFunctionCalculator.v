//toplevel module
module FourFunctionCalculator(SW,KEY,LEDG,HEX7,HEX6,HEX5,HEX4,HEX3,HEX2,HEX1,HEX0,CLOCK_50);
	input [17:0] SW;
	input[3:0] KEY;
	input CLOCK_50;
	output[8:8] LEDG;
	output[6:0] HEX7,HEX6,HEX5,HEX4,HEX3,HEX2,HEX1,HEX0;
	wire[6:0]  H7,H6,H5,H4,H3,H2,H1,H0;
	wire overflow,output1,output2,clear,add,mult,divide,subtract,resultOP;
	wire [10:0] switchNumber = SW[10:0];
	wire signed [10:0] outputRes;
	//wire[4:0] states;
	assign clear = SW[17] & ~KEY[0];
	assign add = ~SW[17] & ~KEY[3];
	assign mult =  ~SW[17] & ~KEY[1];
	assign divide =  ~SW[17] & ~KEY[0];
	assign subtract =  ~SW[17] & ~KEY[2];
	assign resultOP =  SW[17] & ~KEY[3];
	
	FourFuncCalc #(.W(11)) calc1(CLOCK_50, clear, resultOP, add, subtract, mult, divide, switchNumber, outputRes, overflow);
	Binary_to_7SEG bseg1(switchNumber, 0, H7, H6, H5, H4, output1);
	Binary_to_7SEG bseg2(outputRes, 1, H3, H2, H1, H0, output2);
	assign LEDG[8] = overflow;
	assign HEX7 = output1 ? 7'b0111111:H7;
	assign HEX6 = output1 ? 7'b0111111:H6;
	assign HEX5 = output1 ? 7'b0111111:H5;
	assign HEX4 = output1 ? 7'b0111111:H4;
	assign HEX3 = overflow ? 7'b0111111:H3;
	assign HEX2 = overflow ? 7'b0111111:H2;
	assign HEX1 = overflow ? 7'b0111111:H1;
	assign HEX0 = overflow ? 7'b0111111:H0;
endmodule
	
	