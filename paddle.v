module paddle(keyLeft, keyRight, gameOver, paddleX, paddleY, ballY, colour, clock, slowreset);
	
	//imputs from the KEYS on board
	//controlling left-most bit of paddle
	input [6:0] ballY; 
	
	input 				keyLeft, keyRight, clock, slowreset; 
	//input [6:0]			ballY;
	output reg [7:0]  paddleX;
	output reg [6:0] 	paddleY; 
	input					gameOver; 
	output reg [2:0] 	colour; 
	parameter [2:0] 	idleOn = 3'b000, idleOff = 3'b011, R = 3'b010, L = 3'b001, initialState = 3'b111;
	reg [2:0] 			currState;
	reg [2:0] 			nextPaddleState;
	reg [7:0]			inPadX;
	wire [7:0]			paddleXw; 
	wire [4:0]			countWire;
	reg [1:0]			keys;
	wire					clock1s;
	wire [25:0]			slowCounter;
	wire [7:0] 			bottomErase; 
	
	counter BrendansCounter( //counter for drawing all 25 pixels of paddle
		.clock(clock), 
		.count(countWire[4:0]), 
		.reset(slowreset)
	);
	
	slowClock BGsclock( //this clock slows clock time
		.clock(clock), 
		.tick(clock1s),
		.resetn(slowreset),
		.counter(slowCounter[25:0])
	);
	
	paddleXReg BrendansReg (
		.d(inPadX[7:0]), 
		.q(paddleXw[7:0]), 
		.clk(clock), 
		.resetn(slowreset)
	);
	
	bottomEraseCounter eraseC(
		.clock(clock), 
		.count(bottomErase[7:0]),
		.resetn(slowreset) 
	);

	//start the paddle in the middle of the screen
	
	
	//FSM
	always @ (posedge clock) begin //USED TO BE SLOW CLOCK
			
		paddleY[6:0] = 7'd119; //assign the y-coordinate to the bottom of screen, travels solely horizontally
		
		
			case (currState[2:0])
			
				idleOff: begin
						if ((keyRight == 0) && (paddleXw[7:0] < 103))
							nextPaddleState[2:0] = R;
						else if ((keyLeft == 0) && (paddleXw[7:0] > 15))
							nextPaddleState[2:0] = L;
						else
							nextPaddleState[2:0] = idleOff;			
					end
					
					L: begin
						if(paddleXw[7:0] < 15)
							nextPaddleState[2:0] = idleOff; 
						else if (keyRight == 0)
							nextPaddleState[2:0] = idleOn;
						else if (keyLeft == 1)
							nextPaddleState[2:0] = idleOff;
						else 
							nextPaddleState[2:0] = L;							
					end
					
					R: begin
						if(paddleXw[7:0] > 103)
							nextPaddleState[2:0] = idleOff; 
						else if (keyLeft == 0)
							nextPaddleState[2:0] = idleOn;
						else if (keyRight == 1)
							nextPaddleState[2:0] = idleOff;
						else 
							nextPaddleState[2:0] = R;
					end
					
					idleOn: begin
						if ((keyLeft == 1) && (paddleXw[7:0] < 103))
							nextPaddleState[2:0] = R;						
						else if((keyRight == 1) && (paddleXw[7:0] > 15))
							nextPaddleState[2:0] = L;						
						else
							nextPaddleState[2:0] = idleOn;	
					end
					
					initialState: begin
						nextPaddleState[2:0] = idleOff; 
					end
					
					
					default: begin
						nextPaddleState[2:0] = initialState; 
					end
					
				endcase
			
		end		
	
	
	always @ (posedge clock) begin 
		if(slowreset == 0) 
			currState[2:0] <= initialState; 
		else if((gameOver == 1) && ((ballY[6:0] > 7'd115)))
			currState[2:0] <= initialState;
		else
			currState[2:0] <= nextPaddleState[2:0]; 
	end
		
	always @ (posedge clock) begin //erasing and redrawing paddle		
		
		if(slowreset == 0) 
			colour[2:0] <= 3'b000; 
			
		else begin
		
			case (currState[2:0])	
			
				L: begin
					
					if(slowCounter[25:0] < 2000) begin
						colour[2:0] <= 3'b000;
						paddleX[7:0] <= bottomErase[7:0];
					end
					
					else begin
						colour[2:0] <= 3'b111;
						paddleX[7:0] <= paddleXw[7:0] + countWire[4:0];
					end
					
				end

				R: begin
					
					if(slowCounter[25:0] < 2000) begin
						colour[2:0] <= 3'b000;
						paddleX[7:0] <= bottomErase[7:0]; 
					end
					
					else begin
						colour[2:0] <= 3'b111;
						paddleX[7:0] <= paddleXw[7:0] + countWire[4:0];
					end
				end	
				
				idleOff: begin
				
					if(slowCounter[25:0] < 2000) begin
						colour[2:0] <= 3'b000;
						paddleX[7:0] <= bottomErase[7:0]; 
					end
					
					else begin
						colour[2:0] <= 3'b111;
						paddleX[7:0] <= paddleXw[7:0] + countWire[4:0];
					end
					
				end
				
				idleOn: begin
				
					if(slowCounter[25:0] < 2000) begin
						colour[2:0] <= 3'b000;
						paddleX[7:0] <= bottomErase[7:0]; 
					end
					
					else begin
						colour[2:0] <= 3'b111;
						paddleX[7:0] <= paddleXw[7:0] + countWire[4:0];
					end
					
				end
				
				initialState: begin
				
					if(slowCounter[25:0] < 2000) begin
						colour[2:0] <= 3'b000;
						paddleX[7:0] <= bottomErase[7:0];
					end
					
					else begin
						colour[2:0] <= 3'b111;
						paddleX[7:0] <= paddleXw[7:0] + countWire[4:0];
					end
						
				end
				
				default: begin
					colour[2:0] <= 3'b000; 
					paddleX[7:0] <= bottomErase[7:0];
				end
				
			endcase
		end	
	
	end	
	
	
	always @ (posedge clock1s) begin
	
		case(currState[2:0])
			idleOff: begin						
				inPadX[7:0] = paddleXw[7:0]; 
			end
				
			idleOn: begin			
				inPadX[7:0] = paddleXw[7:0]; 
			end			
			
			L: begin		
				inPadX[7:0] = paddleXw[7:0] - 1;				
			end
						
			R: begin		
				inPadX[7:0] = paddleXw[7:0] + 1; 
			end
		
			initialState: begin
				inPadX[7:0] = 8'd60; 
			end
		
			default:
				inPadX[7:0] = paddleXw[7:0]; 
				
		endcase

	end
	
	
endmodule


module paddleXReg(d, q, clk, resetn); 
//input is coord (x)
	input clk, resetn;
	input [7:0] d;
	output reg [7:0] q;
	
//register to store the paddle's x coordinate

	always@(posedge clk, negedge resetn) begin
		if(resetn == 0)
			q[7:0] <= 53;
		else
			q[7:0] <= d[7:0];
	end
	
endmodule


module counter(clock, count, reset); //downcounter from 24 to 0
	input 					clock, reset;
	output reg [4:0] 		count;
	
	always @ (posedge clock) begin
		if (reset == 0)
			count[4:0] <= 24; //set count back to 24 when reset
		
		else if (count[4:0] == 0)
			count[4:0] <= 24; //set count back to 24 when it reaches 0 (start counting again)
			
		else
			count[4:0] <= count[4:0] - 1'b1; //decrement count	
	end
	
endmodule 

module bottomEraseCounter(clock, count, resetn); //downcounter from 129 to 14 to erase all pixels in bottom row
	input 					clock, resetn;
	output reg [7:0] 		count;
	
	always @ (posedge clock) begin
		if (resetn == 0)
			count[7:0] <= 8'd129; //set count back to 129 when game is over (reset)
		
		else if (count[7:0] == 14)
			count[7:0] <= 129; //set count back to 129 when it reaches 14 (start counting again)
			
		else
			count[7:0] <= count[7:0] - 1'b1; //decrement count	
	end
	
endmodule 



module slowClock(clock, tick, resetn, counter);
	input clock;
	input resetn; 
	output tick;
	output reg [25:0] counter; 
	
	always @(posedge clock, negedge resetn) begin
		if(resetn == 1'b0)
			counter[25:0] <= 26'd0; 
		else begin
			if(counter[25:0] == 26'd1250000)  //1,250,000 clock cycles
				counter[25:0] <= 0; 
			else
				counter[25:0] <= counter[25:0] + 1'b1;
		end
	end
	
	assign tick = (counter[25:0] == 26'd1250000) ? 1:0 ;
	
endmodule 




