module seg7letters(i, o);
	input [3:0]i;
	output reg [0:6] o;
	
	parameter P = 4'b0000, A = 4'b0001, D = 4'b0010, 
		L = 4'b0011, E = 4'b0100, U = 4'b0101, R = 4'b0110, B = 4'b0111, space = 4'b1000, V = 4'b1001;
	
	always @ (*) begin

		case (i[3:0])
			P: o[0:6] 		<= 7'b0011000;
			A: o[0:6] 		<= 7'b0001000;			
			D: o[0:6] 		<= 7'b1000010;			
			L: o[0:6] 		<= 7'b1110001;			
			E: o[0:6] 		<= 7'b0110000;			
			U: o[0:6] 		<= 7'b1000001;			
			R: o[0:6] 		<= 7'b1111010;			
			B: o[0:6] 		<= 7'b0000000;			
			space: o[0:6]  <= 7'b1111111;
			V: o[0:6]		<= 7'b1100011;
			
		endcase
		
	end
	
endmodule

module seg7numbers(i, o);
	input [3:0] i;
	output reg [0:6] o;
	
	always @(*) begin
	
		case (i[3:0])
			0: o[0:6] = 7'b 0000001;
			1: o[0:6] = 7'b 1001111;
			2: o[0:6] = 7'b 0010010;
			3: o[0:6] = 7'b 0000110;
			4: o[0:6] = 7'b 1001100;
			5: o[0:6] = 7'b 0100100;
			6: o[0:6] = 7'b 0100000;
			7: o[0:6] = 7'b 0001111;
			8: o[0:6] = 7'b 0000000;
			9: o[0:6] = 7'b 0000100;
			default: o[0:6] = 7'b 1111111;
		endcase
		
	end
	
endmodule
	