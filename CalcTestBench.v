// ModelSim allows the use of "generate".
// This module defines a parameterized W-bit RCA adder/dubtsctor


// Four-Function Calculator TestBench
`timescale 1ns/100ps
module TestBench();
	parameter WIDTH = 11;							// Data bit width

// Inputs and Outputs
	reg Clock;
	reg Clear;											// C button
	reg Equals;											// = button: displays result so far; does not repeat previous operation
	reg Add;												// + button
	reg Subtract;										// - button
	reg Multiply;										// x button (multiply)
	reg Divide;											// Divide button
	reg [WIDTH-1:0] NumberSM; 					// Must be entered in sign-magnitude on SW[W-1:0]
	wire signed [WIDTH-1:0] Result;
	wire Overflow;
	wire CantDisplay;
	//wire [4:0] State;

	wire signed [WIDTH-1:0] NumberTC;
	SM2TC #(.width(WIDTH)) SM2TC1(NumberSM, NumberTC);
	FourFuncCalc #(.W(WIDTH)) FFC(Clock, Clear, Equals, Add, Subtract, Multiply, Divide, NumberSM, Result, Overflow);

	
// Define 10 ns Clock
	always #5 Clock = ~Clock;

	initial
	begin
		Clock = 0; Clear = 1;
		#20; Clear = 0;

	
//  1 + 2 = 3
		/*#10; Equals = 1; NumberSM = 1; 
		#10; Equals = 0;

		#20; Add = 1;
		#20; Add = 0;
		#20; Equals = 1; NumberSM = 2; 
		#20; Equals = 0;*/
// 1+3-4
		/*#10; Equals = 1; NumberSM = 1; 
		#10; Equals = 0;

		#20; Add = 1;
		#20; Add = 0;
		#20; Equals = 1; NumberSM = 3; 
		#20; Equals = 0;
		
		#30; Subtract = 1;
		#30; Subtract = 0;
		#30; Equals = 1; NumberSM = 4;
		#30; Equals = 0;*/

//1023 +(-1023)
		/*#10; Equals = 1; NumberSM = 1023; 
		#10; Equals = 0;

		#20; Add = 1;
		#20; Add = 0;
		#20; Equals = 1; NumberSM = 11'b 11111111111; 
		#20; Equals = 0;
		*/
//1023+10
		#10; Equals = 1; NumberSM = 1023; 
		#10; Equals = 0;

		#20; Add = 1;
		#20; Add = 0;
		#20; Equals = 1; NumberSM = 10; 
		#20; Equals = 0;

//  1-2 = -1
/*		#20; Subtract = 1;
		#20; Subtract = 0;
		#20; Enter = 1; NumberSM = 2;
		#20; Enter = 0;
*/
		end

endmodule

