module ballFSM(ballX, clock, paddle_X, ballY, start, gameOver, colour, resetn); 
	
	input [7:0]paddle_X; 
	input clock, resetn, start;
	
	output reg gameOver; 
	
	output reg [2:0] colour; 
	output reg [7:0] ballX;
	output reg [6:0] ballY;
	
	reg [2:0] currentState;
	reg [2:0] nextBallState; 
	
	parameter [2:0] upRight = 3'b000, upLeft = 3'b001, downLeft = 3'b010, 
								downRight = 3'b011, initialPos = 3'b100, gameOverState = 3'b101; 
	
	//input to coordinate registers
	reg [7:0] inBallX;
	reg [6:0] inBallY; 
	
	//output from coordinate registers
	wire [7:0] outBallX;
	wire [6:0] outBallY;
	
	wire slowClock; 
	wire [25:0] slowCounter;
	
	//constantly counts from 0 to 24
	wire [4:0] countWire; 
	
	//these wires plot the 2x2 box that is the ball
	wire xplotwire;
	wire yplotwire;
	
	
	wire [7:0] xErase; 
	wire [6:0] yErase; 
	
	wire[7:0] eraseRow;
	
	
	//register to store x coordinate
	ballXReg xBall(
		.d(inBallX[7:0]), 
		.q(outBallX[7:0]), 
		.clk(clock), 
		.reset(resetn)
	);
	
	//register to store y coordinate	
	ballYReg yBall(
		.d(inBallY[6:0]), 
		.q(outBallY[6:0]), 
		.clk(clock), 
		.reset(resetn)
	);

	//this clock slows clock time
	slowClockBall KMsclock( 
		.clock(clock), 
		.tick(slowClock),
		.resetn(resetn),
		.counter(slowCounter)
		//.gameOver(gameOver)
	);	
	
	//module to draw the ball 
	plottingClock brendansOtherClock(
		.clock(clock), 
		.xplot(xplotwire), 
		.yplot(yplotwire), 
		.resetn(resetn)
	);		
	
	//module to erase rows above and below the pixel being controlled	
	erase eraseWires(
		.clock(clock),
		.eraseX(xErase[7:0]),
		.eraseY(yErase[6:0]),
		.ballY(outBallY[6:0]),
		.resetn(start)
	);
	
	//module to erase an entire row 
	bottomEraseCounter botErase(
		.clock(clock), 
		.count(eraseRow[7:0]), 
		.resetn(resetn)
	);
	
	
	counter counterto25( 
		.clock(clock), 
		.count(countWire[4:0]), 
		.reset(1)
	);

	
	
	//controls movement of ball
	always @ (posedge clock) begin 
		
		case(currentState[2:0]) 
			initialPos:
				if(start == 0) //KEY[3] will start the game
					nextBallState[2:0] = downLeft; 
				else
					nextBallState[2:0] = initialPos; 
			
			upLeft:
				if((outBallX[7:0] == 8'd16) || (outBallX[7:0] == 8'd15)) //hit left side
					nextBallState[2:0] = upRight; 
				else if((outBallY[6:0] < 7'd2)) //hit top
					nextBallState[2:0] = downLeft; 
				else
					nextBallState[2:0] = upLeft; 
			
			upRight:
				if((outBallX[7:0] == 8'd127) || (outBallX[7:0] == 8'd128)) //hit right
					nextBallState[2:0] = upLeft; 
				else if((outBallY[6:0] < 7'd2)) //hit top
					nextBallState[2:0] = downRight; 
				else
					nextBallState[2:0] = upRight; 
			
			downLeft:				
				if(((paddle_X[7:0] + countWire[4:0]) == ballX[7:0]) && ((outBallY[6:0] == 7'd114) || (outBallY[6:0] == 7'd115))) //hit pad
					nextBallState[2:0] = upLeft;
				else if((outBallX[7:0] == 8'd16) || (outBallX[7:0] == 8'd15)) //hit left side
					nextBallState[2:0] = downRight; 
				else if(((paddle_X[7:0] + countWire[4:0] )!= ballX[7:0]) && (outBallY[6:0] > 7'd115)) //lost game
					nextBallState[2:0] = gameOverState; 
				else
					nextBallState[2:0] = downLeft; 
			
			downRight:
				if(((paddle_X[7:0] + countWire[4:0]) == ballX[7:0]) && ((outBallY[6:0] == 7'd114) || (outBallY[6:0] == 7'd115))) //hit pad
					nextBallState[2:0] = upRight;
				else if((outBallX[7:0] == 8'd128) || (outBallX[7:0] == 8'd127)) //hit right
					nextBallState[2:0] = downLeft;
				else if(((paddle_X[7:0] + countWire[4:0]) != ballX[7:0]) && (outBallY[6:0] > 7'd115)) //lost game
					nextBallState[2:0] = gameOverState;
				else
					nextBallState[2:0] = downRight;
			
			gameOverState:
				nextBallState[2:0] = initialPos;
				
			default:
				nextBallState[2:0] = initialPos; 
			
		endcase
	
	end
	
	//block to put next state into current, unless reset
	always @ (posedge clock) begin
		
		if(resetn == 0) 
			currentState[2:0] <= initialPos; 
		
		else
			currentState[2:0] <= nextBallState[2:0]; 
	end
	
	
	//block to define the states
	always @ (posedge slowClock) begin
		
		case(currentState[2:0]) 
			
			initialPos: begin			
				inBallX[7:0] = 8'd65; 
				inBallY[6:0] = 7'd1; 
			end
			
			upLeft: begin
				inBallX[7:0] = outBallX[7:0] - 1;
				inBallY[6:0] = outBallY[6:0] - 1; 			
			end
			
			upRight: begin
				inBallX[7:0] = outBallX[7:0] + 1;
				inBallY[6:0] = outBallY[6:0] - 1; 		
			end	
			
			downLeft: begin
				inBallX[7:0] = outBallX[7:0] - 1;
				inBallY[6:0] = outBallY[6:0] + 1; 		
			end						
			
			downRight: begin
				inBallX[7:0] = outBallX[7:0] + 1;
				inBallY[6:0] = outBallY[6:0] + 1; 		
			end	
			
			gameOverState: begin
				inBallX[7:0] = 8'd65; 
				inBallY[6:0] = 7'd1; 
			end
			
			default: begin
				inBallX[7:0] = outBallX[7:0]; 
				inBallY[6:0] = outBallY[6:0]; 			
			end
			
		endcase
	end
	
	
	//block to draw and erase the ball
	always @ (posedge clock) begin
	
	if(resetn == 0) 
		colour[2:0] <= 3'b000; 
	
	else begin
		case (currentState[2:0])
					
			downLeft: begin
//				if (slowCounter[25:0] < 26'd300) begin
//					colour[2:0] <= 3'b000;
//					ballX[7:0] <= eraseRow[7:0];
//					ballY[6:0] <= 7'd118;
//				end				
//				else if (slowCounter[25:0] < 26'd600) begin
//					colour[2:0] <= 3'b000;
//					ballX[7:0] <= eraseRow[7:0];
//					ballY[6:0] <= 7'd117;
//				end				
//				else 
				if(slowCounter[25:0] < 26'd20000) begin
					colour[2:0] <= 3'b000;
					ballX[7:0] <= xErase[7:0];
					ballY[6:0] <= yErase[6:0]; 
				end
				else begin					
					colour[2:0] <= 3'b111;
					ballX [7:0] <= outBallX[7:0] + xplotwire;
					ballY [6:0] <= outBallY[6:0] + yplotwire;
				end 
			end
			
			downRight: begin
//				if (slowCounter[25:0] < 26'd300) begin
//					colour[2:0] <= 3'b000;
//					ballX[7:0] <= eraseRow[7:0];
//					ballY[6:0] <= 7'd118;
//				end				
//				else if (slowCounter[25:0] < 26'd600) begin
//					colour[2:0] <= 3'b000;
//					ballX[7:0] <= eraseRow[7:0];
//					ballY[6:0] <= 7'd117;
//				end
//				else 
				if(slowCounter[25:0] < 26'd20000) begin
					colour[2:0] <= 3'b000;
					ballX[7:0] <= xErase[7:0];
					ballY[6:0] <= yErase[6:0]; 
				end
				else begin					
					colour[2:0] <= 3'b111;
					ballX [7:0] <= outBallX[7:0] + xplotwire;
					ballY [6:0] <= outBallY[6:0] + yplotwire;
				end
			end
			
			upLeft: begin
//				if (slowCounter[25:0] < 26'd300) begin
//					colour[2:0] <= 3'b000;
//					ballX[7:0] <= eraseRow[7:0];
//					ballY[6:0] <= 7'd118;
//				end				
//				else if (slowCounter[25:0] < 26'd600) begin
//					colour[2:0] <= 3'b000;
//					ballX[7:0] <= eraseRow[7:0];
//					ballY[6:0] <= 7'd117;
//				end
//				else 
				if(slowCounter[25:0] < 26'd20000) begin
					colour[2:0] <= 3'b000;
					ballX[7:0] <= xErase[7:0];
					ballY[6:0] <= yErase[6:0]; 
				end
				else begin					
					colour[2:0] <= 3'b111;
					ballX [7:0] <= outBallX[7:0] + xplotwire;
					ballY [6:0] <= outBallY[6:0] + yplotwire;
				end
			end
			
			upRight: begin
//				if (slowCounter[25:0] < 26'd300) begin
//					colour[2:0] <= 3'b000;
//					ballX[7:0] <= eraseRow[7:0];
//					ballY[6:0] <= 7'd118;
//				end				
//				else if (slowCounter[25:0] < 26'd600) begin
//					colour[2:0] <= 3'b000;
//					ballX[7:0] <= eraseRow[7:0];
//					ballY[6:0] <= 7'd117;
//				end
//				else 
				if(slowCounter[25:0] < 26'd20000) begin
					colour[2:0] <= 3'b000;
					ballX[7:0] <= xErase[7:0];
					ballY[6:0] <= yErase[6:0]; 
				end
				else begin					
					colour[2:0] <= 3'b111;
					ballX [7:0] <= outBallX[7:0] + xplotwire;
					ballY [6:0] <= outBallY[6:0] + yplotwire;
				end
			end
			
			initialPos: begin
				if (slowCounter[25:0] < 26'd300) begin
					colour[2:0] <= 3'b000;
					ballX[7:0] <= eraseRow[7:0];
					ballY[6:0] <= 7'd118;
				end				
				else if (slowCounter[25:0] < 26'd600) begin
					colour[2:0] <= 3'b000;
					ballX[7:0] <= eraseRow[7:0];
					ballY[6:0] <= 7'd117;
				end
				else 
				if(slowCounter[25:0] < 26'd20000) begin
					colour[2:0] <= 3'b000;
					ballX[7:0] <= xErase[7:0];
					ballY[6:0] <= yErase[6:0]; 
				end
				else begin					
					colour[2:0] <= 3'b111;
					ballX [7:0] <= outBallX[7:0] + xplotwire;
					ballY [6:0] <= outBallY[6:0] + yplotwire;
				end			
			end
			
			gameOverState: begin
//				if (slowCounter[25:0] < 26'd300) begin
//					colour[2:0] <= 3'b000;
//					ballX[7:0] <= eraseRow[7:0];
//					ballY[6:0] <= 7'd118;
//				end				
//				else if (slowCounter[25:0] < 26'd600) begin
//					colour[2:0] <= 3'b000;
//					ballX[7:0] <= eraseRow[7:0];
//					ballY[6:0] <= 7'd117;
//				end
//				else 
//				if(slowCounter[25:0] < 26'd20000) begin
//					colour[2:0] <= 3'b000;
//					ballX[7:0] <= xErase[7:0];
//					ballY[6:0] <= yErase[6:0]; 
//				end
//				else begin					
//					colour[2:0] <= 3'b000; //used to be white
//					ballX [7:0] <= 7'd + xplotwire;
//					ballY [6:0] <= outBallY[6:0] + yplotwire;
//				end
					
			end
			
			default: begin
					colour[2:0] <= 3'b000;
					ballX[7:0] <= outBallX[7:0];
					ballY[6:0] <= outBallY[6:0]; 
			end
		endcase
	end
	
	end
	
	always @ (posedge clock) begin
		
		//checking if ballX is in the range of the paddle and ballY is 117 (hitting paddle), or it's above the paddle
//			if((ballX[7:0] >= (paddleX[7:0] - 1)) && (ballX[7:0] <= (paddleX[7:0] + 25)))
//				gameOver <= 0;
//			else 
//				gameOver <= 1;
//	end

//
//		if(outBallY[6:0] < 7'd115) 
//			gameOver <= 0; 
//	
//		else begin
//		
			if((outBallX[7:0] >= (paddle_X[7:0] - 8'd1)) && (outBallX[7:0] <= (paddle_X[7:0] + 8'd24)))
				gameOver <= 0;
			else 
				gameOver <= 1;
		
		
//		
//			if (((paddleX[7:0] + countWire[4:0]) == ballX[7:0]))
//				gameOver <= 0;
//		
//			else if (((paddleX[7:0] + countWire[4:0]) == (ballX[7:0] + 1)))
//				gameOver <= 0; 
//		
//			else
//				gameOver <= 1;
		//end

	end	
	
	
endmodule

//register to store the ball's x coordinate
module ballXReg (d, q, clk, reset); 
	//input is coord (x)
	input [7:0] d;
	input clk;
	input reset;
	output reg [7:0] q; 

	always @ (posedge clk) begin
		if (reset == 0)
			q[7:0] <= 8'd65;
		else
			q[7:0] <= d[7:0];
	end
	
endmodule

//register to store the ball's y coordinate
module ballYReg (d, q, clk, reset); 
	//input is coord (y)
	input [6:0]d;
	input clk;
	input reset;
	output reg [6:0]q; 

	always @ (posedge clk) begin
		if (reset == 0)
			q[6:0] <= 7'd1;
		else
			q[6:0] <= d[6:0];
	end
	
endmodule


 

//module to draw the ball
module plottingClock(clock, xplot, yplot, resetn);
	input clock;
	input resetn; 
	output reg xplot, yplot;
	reg [1:0] counter; 
	
	always @(posedge clock) begin
		if((resetn == 0) || (counter[1:0] > 2'd3))
			counter[1:0] <= 0; 
			
		else begin
			if(counter[1:0] == 2'd0) begin
				xplot <= 0; 
				yplot <= 0;
			end
			
			else if (counter[1:0] == 2'd1) begin
				xplot <= 0; 
				yplot <= 1;
			end
			
			else if (counter[1:0] == 2'd2) begin
				xplot <= 1; 
				yplot <= 0;
			end
			
			else if (counter[1:0] == 2'd3) begin
				xplot <= 1; 
				yplot <= 1;
			end
			
			counter[1:0] <= counter[1:0] + 1'b1;						
		end
	end
	
	
endmodule 



//slowclock to control ball
module slowClockBall(clock, tick, resetn, counter);
	input clock;
	input resetn; 
	output tick;
	output reg [25:0] counter; 
	 
	always @(posedge clock) begin
		if(resetn == 0)
			counter[25:0] <= 26'd0; 
		else begin
			if(counter[25:0] == 26'd2000000)
				counter[25:0] <= 26'd0; 
			else
				counter[25:0] <= counter[25:0] + 1'b1;
		end
	end
	
	assign tick = (counter[25:0] == 26'd2000000) ? 1 : 0 ;
	
endmodule



//module to detect collision
//module compareCoords(paddleX, ballX, ballY, gameOver, clock);
//	input clock; 
//	input [7:0]paddleX; 
//	input [7:0]ballX;
//	input [6:0]ballY; 
//	output reg gameOver; 
//	wire [4:0] countWire;
//
//	//counter for drawing all 25 pixels of paddle
//	counter counterto25( 
//		.clock(clock), 
//		.count(countWire[4:0]), 
//		.reset(1)
//	);
//
//	always @ (posedge clock) begin
//		
//		//checking if ballX is in the range of the paddle and ballY is 117 (hitting paddle), or it's above the paddle
////			if((ballX[7:0] >= (paddleX[7:0] - 1)) && (ballX[7:0] <= (paddleX[7:0] + 25)))
////				gameOver <= 0;
////			else 
////				gameOver <= 1;
////	end
//
//
//		if(ballY[6:0] < 7'd117) 
//			gameOver <= 0; 
//	
//		else begin
//		
//			if((ballX[7:0] >= (paddleX[7:0] - 8'd1)) && (ballX[7:0] <= (paddleX[7:0] + 8'd24)))
//				gameOver <= 0;
//			else 
//				gameOver <= 1;
//		
//		
////		
////			if (((paddleX[7:0] + countWire[4:0]) == ballX[7:0]))
////				gameOver <= 0;
////		
////			else if (((paddleX[7:0] + countWire[4:0]) == (ballX[7:0] + 1)))
////				gameOver <= 0; 
////		
////			else
////				gameOver <= 1;
//		end
//
//	end
//	
////			if(paddleX[7:0] == (ballX[7:0] - 1))
////				gameOver <= 0; 
////			else if(paddleX[7:0] == ballX[7:0]) 
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd1) == ballX[7:0])
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd2) == ballX[7:0]) 
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd3) == ballX[7:0]) 
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd4) == ballX[7:0]) 
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd5) == ballX[7:0]) 
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd6) == ballX[7:0]) 
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd7) == ballX[7:0]) 
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd8) == ballX[7:0]) 
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd9) == ballX[7:0]) 
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd10) == ballX[7:0]) 
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd11) == ballX[7:0])
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd12) == ballX[7:0]) 
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd13) == ballX[7:0]) 
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd14) == ballX[7:0]) 
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd15) == ballX[7:0]) 
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd16) == ballX[7:0]) 
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd17) == ballX[7:0]) 
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd18) == ballX[7:0]) 
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd19) == ballX[7:0]) 
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd20) == ballX[7:0]) 
////				gameOver <= 0;
////			else if((paddleX[7:0] + 8'd21) == ballX[7:0]) 
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd22) == ballX[7:0]) 
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd23) == ballX[7:0])
////				gameOver <= 0; 
////			else if((paddleX[7:0] + 8'd24) == ballX[7:0]) 
////				gameOver <= 0;
////			else
////				gameOver <= 1;
////	end
//
//endmodule
