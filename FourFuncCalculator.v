
module FourFuncCalc1
	#(parameter W = 11)			// Default bit width
	(Clock, Clear, Equals, Add, Subtract, Multiply, Divide, Number, Result, Overflow, State);
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
	output signed [WW-1:0] Result;		// Calculation result in two's complement
	output Overflow;				// Indicates result can't be represented in W bits
	wire signed [W-1 :0] R;

	output [5:0] State;
	
			// Calculation result in two's complement


//****************************************************************************************************
// Datapath Components
//****************************************************************************************************


//----------------------------------------------------------------------------------------------------
// Registers
// For each register, declare it along with the controller commands that
// are used to update its state following the example for register A
//----------------------------------------------------------------------------------------------------
	
	reg signed [W-1:0] A;			// Accumulator
	wire CLR_A, LD_A;			// CLR_A: A <= 0; LD_A: A <= Q
	
		
	reg signed [W-1:0] N_TC;
	wire LD_N;
	
	reg signed [WW+1:0] PM;
	reg [BoothIter-1:0] CTR;
	
	
	reg signed [W-1:0] M;
		reg signed [W-1:0] P;
  
//----------------------------------------------------------------------------------------------------
// Number Converters
// Instantiate the three number converters following the example of SM2TC1
//----------------------------------------------------------------------------------------------------

	wire signed [W-1:0] NumberTC;	// Two's complement of Number
	SM2TC #(.width(W)) SM2TC1(Number, NumberTC);


//----------------------------------------------------------------------------------------------------
// MUXes
// Use conditional assignments to create the various MUXes
// following the example for MUX Y1
//----------------------------------------------------------------------------------------------------
	
	//wire SEL_P;
	//wire signed [W-1:0] Y1; 									
	//assign Y1 = SEL_P? PM[WW:W+1] : Y3;	// 1: Y1 = P; 0: Y1 = Y3
	
	wire SEL_N;
	wire SEL_Q;
	wire SEL_M;
	wire SEL_P;
	wire SEL_D;
	
	
	
	wire signed [W-1:0] Y1;
	wire signed [W-1:0] Y2;
	wire signed [W-1:0] Y3;
	wire signed [W-1:0] Y4;
	wire signed [W-1:0] Y5;
	wire signed [W-1:0] Y6;
//	wire signed [W-1:0] Y7;

	//assign Y7 = SEL_A? |D_SM| : Result;
	assign Y6 = SEL_N? Y2: Y4;
	//assign Y5 = SEL_Q? Q_TC: Y4;
	assign Y4 = SEL_M? PM[W:1]: R;
	assign Y3 =  A;
		//assign Y3 = SEL_D? D: A;

	//assign Y2 = SEL_D? |N_SM| : N_TC;
	assign Y2 = N_TC;
	assign Y1 = SEL_P? PM[WW:W+1] : Y3;
	
  
//----------------------------------------------------------------------------------------------------
// Adder/Subtractor 	
//----------------------------------------------------------------------------------------------------

	wire c0;					// 0: Add, 1: Subtract
	wire ovf;					// Overflow
	AddSub #(.W(W)) AddSub(Y1, Y2, c0, R, ovf);
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

	reg [5:0] X, X_Next;
	assign State = X;

	localparam XInit		= 'd0;	// Power-on state (A == 0)
	localparam XClear	= 'd1;		// Pick numeric assignments
	localparam XLoadA	= 'd2;
	localparam XResult	= 'd3;
	localparam XOVF = 'd4;
	localparam XADD = 'd5;
	localparam XdoAdd = 'd6;
	localparam XSUB = 'd7;
	localparam XdoSub = 'd8;
	localparam XALoadN = 'd9;
	localparam XSLoadN = 'd10;
	localparam XMUL = 'd11;
	localparam XCheck = 'd12;
	localparam XNext = 'd13;
	localparam XMore = 'd14;
	localparam XDone = 'd15;
	localparam XMADD = 'd16;
	localparam XMSUB = 'd17;
	localparam XMLoadN = 'd18;



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
			else if (Subtract)
				X_Next <= XSUB;
			else if (Add)
				X_Next <= XADD;
			
			else if (Multiply)
				X_Next <= XMUL;
			//else if (Divide)
			//	X_Next <= XDiv;
			else
				X_Next <= XInit;
				
		XClear: 
			X_Next <= XInit;
		
		XLoadA:
			if(Clear)
				X_Next <= XClear;
			else if (Add)
			X_Next <= XADD;
			else if (Subtract)
			X_Next <= XSUB;
			else if (Multiply)
			X_Next <= XMUL;
			else
			X_Next <= XResult;
			
		XResult:
			if (Add)
			X_Next <= XADD;
			else if (Subtract)
			X_Next <= XSUB;
			else if (Multiply)
			X_Next <= XMUL;
			else if (Clear)
			X_Next <= XClear;
			else 
			X_Next <= XResult;
			
		XADD:
			if(Equals)
				X_Next <= XALoadN;
			else if (Clear)
				X_Next <= XClear;
			else if (Subtract)
				X_Next <= XSUB;
			else if (Multiply)
				X_Next <= XMUL;
			else
			X_Next <= XADD;

		XdoAdd:
			if (ovf)
			X_Next <= XOVF;
			else
			X_Next <= XResult;
		XdoSub:
			if (ovf)
			X_Next <= XOVF;
			else
			X_Next <= XResult;
		XOVF:
			if (Clear)
			X_Next <= XClear;
			else
			X_Next <= XOVF;
		XSUB:
			if (Equals)
				X_Next <= XSLoadN;
			else if (Clear)
				X_Next <= XClear;
			else if (Add)
				X_Next <= XADD;
			else if (Multiply)
				X_Next <= XMUL;
			else
			X_Next <= XSUB;
		XSLoadN:
			X_Next <= XdoSub;
		XALoadN:
			X_Next <= XdoAdd;
		XMUL:
			if (Equals)
				X_Next <= XMLoadN;
			else if (Clear)
				X_Next <= XClear;
			else if (Add)
				X_Next <= XADD;
			else if (Subtract)
				X_Next <= XSUB;
			else
			X_Next <= XMUL;
		XCheck:
			if(~PM[1] & PM[0])
				X_Next <= XMADD;
			else if (PM[1] & ~PM[0])
				X_Next <= XMSUB;
			else
				X_Next <= XNext;
		
		XMADD:
			X_Next <= XNext;
		XMSUB:
			X_Next <= XNext;
		XNext:
			X_Next <= XMore;
		
		XMore:
			if(CTR == 'd0)
				X_Next <= XDone;
			else
				X_Next <= XCheck;
		
		XMLoadN:

				X_Next <= XCheck;
		 XDone:
			if(PM[W+1] ^ PM[W])
				X_Next <= XOVF;
			else
				X_Next <= XResult;

	endcase
  
  
//----------------------------------------------------------------------------------------------------
// Initial state on power-on
// Here's a freebie!
//----------------------------------------------------------------------------------------------------

	initial begin
		X <= XClear;
		A <= 'd0;
		N_TC <= 'd0;
	//	N_SM <= 'd0;
		PM <= 'd0;      			//WW+1'd0;
		CTR = W;
	end


//----------------------------------------------------------------------------------------------------
// Controller Commands to Datapath
// No freebies here!
// Using assign statements, you need to figure when the various controller
// commands are asserted in order to properly implement the datapath
// operations.
//----------------------------------------------------------------------------------------------------

	assign LD_A = (X == XLoadA || X == XdoAdd || X== XdoSub || X==XDone); 
	assign CLR_A = (X == XClear);
	 assign LD_N = (X == XInit || X== XALoadN || X == XSLoadN || X==XMLoadN);
	 assign SEL_N = (X==XLoadA || X == XADD || X == XSUB || X == XMUL);
	 assign c0 = ( X == XdoSub || X == XMSUB);
	 
	 
	assign SEL_P = (X == XMUL || X == XCheck || X == XMADD || X == XMSUB);
	assign SEL_M = (X==XDone);
	assign M_LD = (X == XMLoadN);
	assign P_LD = (X == XMADD) || (X == XMSUB);
	assign PM_ASR = (X == XNext);
	assign CTR_DN = (X == XNext);
	assign AllDone = (X == XDone);

//----------------------------------------------------------------------------------------------------  
// Controller State Update
//----------------------------------------------------------------------------------------------------

	always @(posedge Clock)
		if (Clear)
			X <= XClear;
		else
			X <= X_Next;
	
    
//----------------------------------------------------------------------------------------------------
// Datapath State Update
// This part too is your responsibility to figure out.
// But there is a hint to get you started.
//----------------------------------------------------------------------------------------------------
wire signed [W:0] ZERO; 					// (W+1)-bit 0 since `(W+1)'d0 does not work
	assign ZERO = 'd0;
	always @(posedge Clock)
	
		
	
	if (Clear)
			begin
				PM[WW+1:W+1] <= 'd0;
				PM[0] <= 0;
				CTR <= W;
			end
  else
			begin
			N_TC <= LD_N ? NumberTC : N_TC;
			A <= CLR_A ? 0: (LD_A? Y6 : A);
			//M <= M_LD? A : M;
			//P <= P_LD? R: P;
				PM <=
					(M_LD? $signed({ZERO, A, 1'b0}) :				// Load M
						(P_LD ? $signed({PSgn, R, PM[W:0]}) :	// Add/Sub
							(PM_ASR ? PM >>> 1 :								// ASR
							 PM																	// Unchanged
							)        
						)
					);
				CTR <= M_LD ? W : CTR_DN ? CTR - 1 : CTR;
			end
	
 
//---------------------------------------------------------------------------------------------------- 
// Calculator Outputs
// The two outputs are Result and Overflow, get it?
//----------------------------------------------------------------------------------------------------
	//assign ResultAB = A;
	assign Overflow = (X == XOVF);
	assign Result =  A;
	//if multiply set result = P else set result = A
//result twos complement, 22 clock speed 
	
endmodule