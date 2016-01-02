module paddle_game
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,
		SW,
		// The ports below are for the VGA output.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK,						//	VGA BLANK
		VGA_SYNC,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B,   						//	VGA Blue[9:0]
		HEX0,
		HEX1,
		HEX2,
		HEX3,
		HEX4,
		HEX5
	);

	input			CLOCK_50;				//	50 MHz
	
	// Declare your inputs and outputs here
	input[3:0] KEY;
	input[9:0] SW; 
	wire [2:0] colour;
	
	//coordinates sent to VGA module
	wire [7:0] x;
	wire [6:0] y; 
	
	//outputs from paddle FSM
	wire [7:0] paddleX; 
	wire [6:0] paddleY; 
	wire [2:0] paddleColour;
	
	//outputs from ball FSM
	wire [7:0] ballX;
	wire [6:0] ballY; 
	wire [2:0] ballColour; 
	
	wire[25:0] counter;
	
	// chooses whether the ball or paddle's coordinates and colour are being sent to VGA
	wire selectSignal; 
	
	//1 if game over, else 0
	wire gameOver;
		
	wire resetCounter;
	
	//reset for the VGA
	wire resetn; 
	assign resetn = SW[9];
		
	wire [3:0] P, A, D, L, E, U, R, B, sp;
	
	assign P			= 4'b0000;
	assign A 		= 4'b0001;
	assign D 		= 4'b0010;
	assign L 		= 4'b0011;
	assign E 		= 4'b0100;
	assign U 		= 4'b0101;
	assign R 		= 4'b0110;
	assign B 		= 4'b0111;
	assign sp 		= 4'b1000;
	
		
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK;				//	VGA BLANK
	output			VGA_SYNC;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	output reg [0:6] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	
	wire [0:6] Phw, Ahw, Dhw, Lhw, Ehw, Uhw, Rhw, Bhw, sphw;
	
	//module to produce select signal of the mux 
	doubleSlowClock selectSig(
		.clock(CLOCK_50),
		.select(selectSignal),
		.resetn(KEY[3])	
	);
	
	//mux to send x coordinates to VGAt
	mux2to1X xCoords(
		.a(paddleX[7:0]), 
		.b(ballX[7:0]),
		.s(selectSignal), 
		.o(x[7:0])
	); 
	
	//mux to send y coordinates to VGA
	mux2to1Y yCoords(
		.a(paddleY[6:0]), 
		.b(ballY[6:0]),
		.s(selectSignal), 
		.o(y[6:0])
	); 
	
	//mux to send colour to the VGA
	mux2to1Colour Colour(
		.a(paddleColour[2:0]),
		.b(ballColour[2:0]),
		.s(selectSignal),
		.o(colour[2:0])
	);
	
	seg7letters Ph		( .i(P [3:0]), .o(Phw [0:6]) );
	seg7letters Ah		( .i(A [3:0]), .o(Ahw [0:6]) );
	seg7letters Dh		( .i(D [3:0]), .o(Dhw [0:6]) );
	seg7letters Lh		( .i(L [3:0]), .o(Lhw [0:6]) );
	seg7letters Eh		( .i(E [3:0]), .o(Ehw [0:6]) );
	seg7letters Uh 	( .i(U [3:0]), .o(Uhw [0:6]) );
	seg7letters Rh  	( .i(R [3:0]), .o(Rhw [0:6]) );
	seg7letters Bh  	( .i(B [3:0]), .o(Bhw [0:6]) );	
	seg7letters spceH ( .i(sp[3:0]), .o(sphw[0:6]) );
	
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour[2:0]),
			.x(x[7:0]),
			.y(y[6:0]),
			.plot(1),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK),
			.VGA_SYNC(VGA_SYNC),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "background.mif";
	
  //module that controls the paddle
	paddle ourPaddle(
		.keyLeft(KEY[1]), 
		.keyRight(KEY[0]), 
		.gameOver(gameOver), 
		.paddleX(paddleX[7:0]), 
		.paddleY(paddleY[6:0]), 
		.ballY(ballY[6:0]),
		.colour(paddleColour[2:0]), 
		.clock(CLOCK_50),
		.slowreset(SW[3])
	);

	//module that controls the ball
	ballFSM ball_1 (
		.ballX(ballX[7:0]), 
		.clock(CLOCK_50), 
		.start(KEY[3]),
		.paddle_X(paddleX[7:0]), 
		.ballY(ballY[6:0]), 
		.gameOver(gameOver),
		.colour(ballColour[2:0]),
		.resetn(SW[2])
	);
	
	hexmuxcounter muxcount(
		.clock(CLOCK_50), 
		.counter(counter[25:0]), 
		.resetcounter(resetCounter)
	);

	//controls what the HEX displays show
	always @ (posedge CLOCK_50) begin		
		if (gameOver == 1 && ballY[6:0] == 118 ) begin		
		//lost the game, display "Ur bAd" on HEX displays
			if (counter[25:0] < 50000000) begin
				HEX5 [0:6] <= Uhw [0:6];
				HEX4 [0:6] <= Rhw [0:6];
				HEX3 [0:6] <= sphw [0:6];
				HEX2 [0:6] <= Bhw [0:6];
				HEX1 [0:6] <= Ahw [0:6];
				HEX0 [0:6] <= Dhw [0:6];
			end
		end
		
		else begin			
		//haven't lost, display "PAddLE" on HEX displays
			HEX5 [0:6] <= Phw [0:6];
			HEX4 [0:6] <= Ahw [0:6];
			HEX3 [0:6] <= Dhw [0:6];
			HEX2 [0:6] <= Dhw [0:6];
			HEX1 [0:6] <= Lhw [0:6];
			HEX0 [0:6] <= Ehw [0:6];
		end
	end
	
endmodule


//mux module for x-coordinate selection
module mux2to1X (a, b, s, o);
	input [7:0]a;
	input [7:0]b;
	input s;
	output [7:0]o;

	assign o[7:0] = s ? a[7:0] : b[7:0];

endmodule

//mux module for y-coordinate selection
module mux2to1Y (a, b, s, o);
	input [6:0]a;
	input [6:0]b;
	input s;
	output [6:0]o;
	
	assign o[6:0] = s ? a[6:0] : b[6:0];

endmodule

//mux module for colour selection
module mux2to1Colour (a, b, s, o);
	input [2:0]a;
	input [2:0]b;
	input s;
	output [2:0]o;
	
	assign o[2:0] = s ? a[2:0] : b[2:0];

endmodule


module doubleSlowClock(clock, select, resetn);
	input clock;
	input resetn; 
	output reg select;
	reg [25:0] counter; 
	
	always @(posedge clock, negedge resetn) begin
		if(resetn == 1'b0)
			counter[25:0] <= 26'd0; 
		else begin
			if(counter[25:0] == 26'd40000) 
				counter[25:0] <= 26'd0; 
			else
				counter[25:0] <= counter[25:0] + 1'b1;
			
			if (counter[25:0] == 26'd0)
				select <= 1;
			else if (counter[25:0] == 26'd20000)
				select <= 0;				
		end
	end
	
endmodule 


//controls whether "PAddLE" or "Ur bAd" is going to be displayed on HEX
module hexmuxcounter(clock, counter, resetcounter);
	input clock;
	input resetcounter; 
	output reg [25:0] counter; 
	
	initial begin
		counter[25:0] <= 0;
	end
	
	always @(posedge clock, negedge resetcounter) begin
		if(resetcounter == 1'b0)
			counter[25:0] <= 26'd0; 
			
		else begin
			if(counter[25:0] == 26'd50000000) 
				counter[25:0] <= 26'd0; 
			else
				counter[25:0] <= counter[25:0] + 1'b1;						
		end
	end
	
endmodule 

