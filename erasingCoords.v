module erase(clock, eraseX, eraseY, ballY, resetn);

	input clock, resetn;
	input [6:0] ballY;
	output [7:0] eraseX;
	output [6:0] eraseY;
	
	reg [7:0] xCounter;
	reg [6:0] yCounter;
	
	
	always @ (posedge clock) begin
		
		if(resetn == 0) begin
			xCounter[7:0] <= 8'd129;
			yCounter[6:0] <= ballY[6:0] - 5;
		end
		
		else if (xCounter[7:0] == 8'd14) begin //x has reached left boundary, increment y
			xCounter[7:0] <= 8'd129;
			yCounter[6:0] <= yCounter[6:0] + 1'b1;
		end
		
		else if ( yCounter[6:0] == (ballY[6:0] + 5) ) begin //y has reached bottom boundary
			xCounter[7:0] <= xCounter[7:0] - 1'b1;
			yCounter[6:0] <= ballY[6:0] - 5;
		end
		
		else
			xCounter[7:0] <= xCounter[7:0] - 1'b1;
		
	end
	
	assign eraseX[7:0] = xCounter[7:0];
	assign eraseY[6:0] = yCounter[6:0];
	
endmodule
		
	
	
	
	
	
	
	
	
	
	
	
	
	