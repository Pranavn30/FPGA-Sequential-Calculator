// EECS 270
// Lab 7:Four-Function Calculator Template
module FourFuncCalc
	#(parameter W = 11)			// Default bit width
	(Clock, Clear, Equals, Add, Subtract, Multiply, Divide, Number, Result, Overflow);
	localparam WW = 2 * W;		// Double width for Booth multiplier
	localparam BoothIter = $clog2(W);	// Width of Booth Counter
	input Clock;
	input Clear;				// C button
	input Equals;				// = button: displays result so far; does not repeat previous operation
	input Add;					// + button
	input Subtract;				// - button
	input Multiply;				// x button (multiply)
	input Divide;				// / button (division quotient)
	input [W-1:0] Number; 			// Must be entered in sign-magnitude on SW[W-1:0]
	output signed [W-1:0] result;		// Calculation result in two's complement
	output Overflow;			// Indicates result can't be represented in W bits

  
//****************************************************************************************************
// Datapath Components
//****************************************************************************************************


//----------------------------------------------------------------------------------------------------
// Registers
// For each register, declare it along with the controller commands that
// are used to update its state following the example for register A
//----------------------------------------------------------------------------------------------------
	
	reg signed [W-1:0] A;
	reg signed [W-1:0] N_TC// Accumulator
	reg ovf_reg
	wire CLR_A, LD_N;			// CLR_A: A <= 0; LD_A: A <= Q

  
//----------------------------------------------------------------------------------------------------
// Number Converters
// Instantiate the three number converters following the example of SM2TC1
//----------------------------------------------------------------------------------------------------

	wire signed [W-1:0] NumberTC;		// Two's complement of Number
	SM2TC #(.width(W)) SM2TC1(Number, NumberTC);


//----------------------------------------------------------------------------------------------------
// MUXes
// Use conditional assignments to create the various MUXes
// following the example for MUX Y1
//----------------------------------------------------------------------------------------------------
	
	wire SEL_P;
	wire SEL_N;
	wire signed [W-1:0] Y1, Y2, Y3, Y4
	assign Y1 = A;
	assign Y2 = N_TC;
	assign Y4 = SEL_N ? N_TC : result
	//assign Y1 = SEL_P? PM[WW:W+1] : Y3;	// 1: Y1 = P; 0: Y1 = Y3
	//assign Y2 = SELNP? PM[WW:W+1] : Y5;	// 1: Y2 = P; 0: Y2 = Y5

  
//----------------------------------------------------------------------------------------------------
// Adder/Subtractor 
//----------------------------------------------------------------------------------------------------

	wire c0;
	wire signed [W-1:0] R// 0: Add, 1: Subtract
	wire ovf;				// Overflow
	AddSub #(.W(W)) AddSub1(Y1, Y2, c0, R, ovf);
	wire PSgn = R[W-1] ^ ovf;		// Corrected P Sign on Adder/Subtractor overflow


//****************************************************************************************************
/* Datapath Controller
   Suggested Naming Convention for Controller States:
     All names start with X (since the tradtional Q connotes quotient in this project)
     XAdd, XSub, XMul, and XDiv label the start of these operations
     XA: Prefix for addition states (that follow XAdd)
     XS: Prefix for subtraction states (that follow XSub)
     XM: Prefix for multiplication states (that follow XMul)
     XD: Prefix for division states (that follow XDiv)
*/
//****************************************************************************************************


//----------------------------------------------------------------------------------------------------
// Controller State and State Labels
// Replace ? with the size of the state registers X and X_Next after
// you know how many controller states are needed.
// Use localparam declarations to assign labels to numeric states.
// Here are a few "common" states to get you started.
//----------------------------------------------------------------------------------------------------

	reg [?:0] X, X_Next;

	localparam XInit	= 'd0;	// Power-on state (A == 0)
	localparam XClear	= 'd1;	// Pick numeric assignments
	localparam XLoadA	= 'd2;
	localparam XResult	= 'd3;
	localparam XAdd = 'd4;
	localparam XA = 'd5;
	localparam XSub = 'd6;
	localparam XS = 'd7;
	localparam XOvf = 'd8;
	localparam XDisp = 'd9;
	

//----------------------------------------------------------------------------------------------------
// Controller State Transitions
// This is the part of the project that you need to figure out.
// It's best to use ModelSim to simulate and debug the design as it evolves.
// Check the hints in the lab write-up about good practices for using
// ModelSim to make this "chore" manageable.
// The transitions from XInit are given to get you started.
//----------------------------------------------------------------------------------------------------

	always @*
	case (X)
		XInit:
			if (Clear)
				X_Next <= XClear;
			else if (Equals)
				X_Next <= XLoadA;
			else if (Add)
				X_Next <= XAdd;
			else if (Subtract)
				X_Next <= XSub;
			//else if (Multiply)
				//X_Next <= XMul;
			//else if (Divide)
				//X_Next <= XDiv;
			else
				X_Next <= XInit;
				
		XLoadA:
			if (Clear)
				X_Next <= XClear;
			else if (Add)
				X_Next <=XAdd;\
			else if (
			else
				X_Next <= XAdd;
		
		XDisp:
			if(Clear)
				X_Next <= XClear;
			else if (Add)
				X_Next <= XAdd;
			else if(XEquals)
				X_Next <= XDisp;
	endcase
  
  
//----------------------------------------------------------------------------------------------------
// Initial state on power-on
// Here's a freebie!
//----------------------------------------------------------------------------------------------------

	initial begin
		X <= XClear;
		A <= 'd0;
		N_TC <= 'd0;
		N_SM <= 'd0;
		MCounter <= W;		//BoothIter'dW;
		PM <= 'd0;		//WW+1'd0;
	end


//----------------------------------------------------------------------------------------------------
// Controller Commands to Datapath
// No freebies here!
// Using assign statements, you need to figure when the various controller
//	commands are asserted in order to properly implement the datapath
// operations.
//----------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------  
// Controller State Update
//----------------------------------------------------------------------------------------------------

	always @(posedge Clock)
		if (Clear)
			X <= XClear;
		else if (Add)
			X <= X_Next;
		else if(Equals)
			x <= X_Disp;

      
//----------------------------------------------------------------------------------------------------
// Datapath State Update
// This part too is your responsibility to figure out.
// But there is a hint to get you started.
//----------------------------------------------------------------------------------------------------

	always @(posedge Clock)
	begin
		N_TC <= LD_N ? NumberTC : N_TC;
		A <= LD_A ? Y6:A;

	end

 
//---------------------------------------------------------------------------------------------------- 
// Calculator Outputs
// The two outputs are Result and Overflow, get it?
//----------------------------------------------------------------------------------------------------

	assign Result = A;
	assign ovf = ovf_reg
endmodule