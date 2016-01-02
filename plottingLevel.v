
module plottingLevel(clock, level, resetn, counter, gameOver, numX, numY, numColour);
	input clock, resetn;
	input [99:0] level;
	input [25:0] counter;
	input gameOver;
	output reg [7:0] numX;
	output reg [6:0] numY;
	output reg [2:0] numColour;
	reg [7:0] startingX;
	wire [6:0] startingY;
	
	assign startingY[6:0] = 6'd67;

	
	plotting0 inst(
		.clock(clock), 
		.resetN(resetn), 
		.gameOver(gameOver),
		.counter(counter[2:0])
	);
	
	always@(posedge clock) begin
	
		if (level[99:0] < 10) begin
			startingX[7:0] <= 7'd143;
			
			if (level[99:0] == 0) begin //plotting 0
				numX[7:0] <= startingX[7:0] + counter[2:0];
				numY[6:0] <= startingY[6:0];
				colour[2:0] <= 3'b010;
				
			end
		end
	end
	
endmodule

module plotting0(clock, resetN, gameOver, counter);

	input clock, resetN, gameOver;
	output reg [2:0] counter; //counter 
	
	initial begin
		counter <= 0;
	end
	
	always @ (posedge clock) begin
	
		if (counter == 4 || resetN || gameOver)
			counter <= 0;
		else
			counter <= counter + 1;		
	end
	
endmodule
