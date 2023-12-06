module datapath(
	input Clock, Resetn, moveForward, moveRight, moveLeft,
	input set_reset_signals, start_race, draw_background, draw_car, draw_over_car, move, draw_start_screen, draw_win_screen,
	output reg DoneDrawBackground, DoneDrawCar, DoneDrawOverCar, FinishedRace, DoneDrawStartScreen, DoneDrawWinScreen,
	output reg[5:0] colourOut,
	output reg[7:0] yOut,
	output reg[8:0] xOut);
	
	//----------------------------------RAM, Registers, and Wires----------------------------------
	
	localparam orientRight          = 0,
				  orientUpRightRight   = 1,	
			     orientUpRight   	  = 2,
				  orientUpUpRight 	  = 3,
			     orientUp        	  = 4,
				  orientUpUpLeft 		  = 5,
				  orientUpLeft    	  = 6,
				  orientUpLeftLeft 	  = 7,
			     orientLeft      	  = 8,
				  orientDownLeftLeft   = 9,
			     orientDownLeft  	  = 10,
				  orientDownDownLeft   = 11,
			     orientDown      	  = 12,
				  orientDownDownRight  = 13,
			     orientDownRight 	  = 14,
				  orientDownRightRight = 15;
	
	
	
	reg[13:0] carAddress = 14'd0;
	reg[16:0] backgroundAddress = 17'd0;
	reg[16:0] startScreenAddress = 17'd0;
	reg[16:0] winScreenAddress = 17'd0;
	reg[9:0] boomAddress = 10'd0;

	wire[5:0] carColourToDisplay;
	wire[5:0] backgroundColourToDisplay;
	wire[5:0] boomColourToDisplay;
	wire[5:0] winScreenColourToDisplay;
	wire[5:0] startScreenColourToDisplay;

	
	// only being used to read, not write
	car_sprite_atlas carAtlas(
		.address(carAddress),
		.clock(Clock),
		.data(6'b000000),
		.wren(1'b0), 
		.q(carColourToDisplay));
		
	trackRam track(
		.address(backgroundAddress),
		.clock(Clock),
		.data(6'b000000),
		.wren(1'b0), 
		.q(backgroundColourToDisplay));

	winScreenRam win(
		.address(winScreenAddress), 
		.clock(Clock),
		.data(6'b000000),
		.wren(1'b0), 
		.q(winScreenColourToDisplay));

	startScreenRam start(
		.address(startScreenAddress), 
		.clock(Clock),
		.data(6'b000000),
		.wren(1'b0), 
		.q(startScreenColourToDisplay));
	
	
	reg pastStartLine = 1'b0;
	reg[7:0] yCount = 8'd0;
	reg[7:0] currentYPosition = 8'd0;
	reg[8:0] xCount = 9'd0;
	reg[8:0] currentXPosition = 9'd0;
	reg[3:0] currentOrientation = orientRight;
	localparam pixelsToMove = 2;
	
	//----------------------------------Operations Based on Input----------------------------------
	
	always@(posedge Clock) begin
	
		//------------------------------------Resetting Signals------------------------------------
		
		if(set_reset_signals) begin
			backgroundAddress <= 17'd0;
			carAddress <= 14'd0;
			startScreenAddress <= 17'd0;
			winScreenAddress <= 17'd0;
			currentXPosition <= 9'd0;
			currentYPosition <= 8'd0;
			xCount <= 9'd0;
			yCount <= 8'd0;
			DoneDrawBackground <= 1'b0;
			DoneDrawCar <= 1'b0;
			DoneDrawOverCar <= 1'b0;
			currentOrientation <= orientRight;
			FinishedRace <= 1'b1;
			pastStartLine <= 1'b0;
			DoneDrawStartScreen <=1'b0;
			DoneDrawWinScreen <= 1'b0;
		end
		
		if(start_race) FinishedRace <= 1'b0;
		
		
		//------------------------------------Drawing Start Screen------------------------------------

		if(draw_start_screen && !DoneDrawStartScreen) begin
		
			colourOut <= startScreenColourToDisplay;
			xOut <= currentXPosition + xCount;
			yOut <= currentYPosition + yCount;
			
			if(xCount == 9'd319 && yCount == 8'd239) begin
				xCount <= 9'd0;
				yCount <= 8'd0;
				
				currentXPosition <= 9'd0;
				currentYPosition <= 8'd0;
				startScreenAddress <= 17'd0;
				DoneDrawStartScreen <= 1'b1;
			end
			else if(xCount == 9'd319) begin
				xCount <= 9'd0;
				yCount <= yCount + 8'd1;
				startScreenAddress <= startScreenAddress + 17'd1;
				DoneDrawStartScreen <= 1'b0;
			end
			else begin
				xCount <= xCount + 9'd1;
				startScreenAddress <= startScreenAddress + 17'd1;
				DoneDrawStartScreen <= 1'b0;
			end
		end
		

		//------------------------------------Drawing Win Screen------------------------------------

		if(draw_win_screen && !DoneDrawWinScreen) begin
		
			colourOut <= winScreenColourToDisplay;
			xOut <= currentXPosition + xCount;
			yOut <= currentYPosition + yCount;
			
			if(xCount == 9'd319 && yCount == 8'd239) begin
				xCount <= 9'd0;
				yCount <= 8'd0;
				
				currentXPosition <= 9'd0;
				currentYPosition <= 8'd0;
				winScreenAddress <= 17'd0;
				DoneDrawWinScreen <= 1'b1;
			end

			else if(xCount == 9'd319) begin
				xCount <= 9'd0;
				yCount <= yCount + 8'd1;
				winScreenAddress <= winScreenAddress + 17'd1;
				DoneDrawWinScreen <= 1'b0;
			end
			else begin
				xCount <= xCount + 9'd1;
				winScreenAddress <= winScreenAddress + 17'd1;
				DoneDrawWinScreen <= 1'b0;
			end
		end
		
	
		//------------------------------------Drawing Background------------------------------------
		
		if(draw_background && !DoneDrawBackground) begin
		
			colourOut <= backgroundColourToDisplay; //colour of sprite at current position
			xOut <= currentXPosition + xCount;
			yOut <= currentYPosition + yCount;
			
			if(xCount == 9'd319 && yCount == 8'd239) begin
				xCount <= 9'd0;
				yCount <= 8'd0;
				
				currentXPosition <= 9'd126; // Starting position of the car
				currentYPosition <= 8'd197;
				backgroundAddress <= (320 * 197) + 126;
				
				DoneDrawBackground <= 1'b1;
			end
			else if(xCount == 9'd319) begin
				xCount <= 9'd0;
				yCount <= yCount + 8'd1;
				backgroundAddress <= backgroundAddress + 17'd1;
				DoneDrawBackground <= 1'b0;
			end
			else begin
				xCount <= xCount + 9'd1;
				backgroundAddress <= backgroundAddress + 17'd1;
				DoneDrawBackground <= 1'b0;
			end
		end
		
		//---------------------------------------Drawing Car---------------------------------------
		
		else if(draw_car && !DoneDrawCar) begin

			if(carColourToDisplay == 6'b100010) begin
				colourOut <= backgroundColourToDisplay;
				xOut <= currentXPosition + xCount;
				yOut <= currentYPosition + yCount;
			end
			else begin
				colourOut <= carColourToDisplay; // Colour of sprite at current position
				xOut <= currentXPosition + xCount;
				yOut <= currentYPosition + yCount;
			end
			if(xCount == 9'd31 && yCount == 8'd31) begin
				xCount <= 9'd0;
				yCount <= 8'd0;
				// Puts background back at starting position of square
				backgroundAddress <= backgroundAddress + (-(320 * 31) - 31);
				DoneDrawCar <= 1'b1;
			end
			else if(xCount == 9'd31) begin
				xCount <= 9'd0;
				yCount <= yCount + 8'd1;
				carAddress <= carAddress + 14'd1;
				// Moves on the next line of addresses for the background
				backgroundAddress <= backgroundAddress + (320 - 31);
				DoneDrawCar <= 1'b0;
			end
			else begin
				xCount <= xCount + 9'd1;
				carAddress <= carAddress + 14'd1;
				backgroundAddress <= backgroundAddress + 17'd1;
				DoneDrawCar <= 1'b0;
			end
			
		end
		
		
		if(draw_over_car && !DoneDrawOverCar) begin
		
			colourOut <= backgroundColourToDisplay; //colour of sprite at current position
			xOut <= currentXPosition + xCount;
			yOut <= currentYPosition + yCount;
			
			if(xCount == 9'd31 && yCount == 8'd31) begin
				xCount <= 9'd0;
				yCount <= 8'd0;
				backgroundAddress <= backgroundAddress + (-(320 * 31) - 31);
				DoneDrawOverCar <= 1'b1;
			end
			else if(xCount == 9'd31) begin
				xCount <= 9'd0;
				yCount <= yCount + 8'd1;
				backgroundAddress <= backgroundAddress + (320 - 31);
				DoneDrawOverCar <= 1'b0;
			end
			else begin
				xCount <= xCount + 9'd1;
				backgroundAddress <= backgroundAddress + 17'd1;
				DoneDrawOverCar <= 1'b0;
			end
		end
		
		//---------------------------------------Moving Car---------------------------------------
		
		if(move) begin
	
			// Signals from drawing are reset to prepare for the next draw
			DoneDrawBackground <= 1'b0;
			DoneDrawCar <= 1'b0;
			DoneDrawOverCar <= 1'b0;
			DoneDrawWinScreen <= 1'b0;
			DoneDrawStartScreen <= 1'b0;

			case(currentOrientation)
				orientRight: begin
					if(moveForward) begin
						carAddress <= orientRight * 1024;
						currentOrientation <= orientRight;
						backgroundAddress <= backgroundAddress + pixelsToMove;
						currentXPosition <= currentXPosition + pixelsToMove;
					end
					else if(moveRight) begin
						carAddress <= orientDownRightRight * 1024; // Moves to a different sprite car_sprite_atlas
						currentOrientation <= orientDownRightRight;
						// Car stays at the same location, no need to change x and y position
					end
					else if (moveLeft) begin
						carAddress <= orientUpRightRight * 1024; // Car stays at the same location
						currentOrientation <= orientUpRightRight;
					end
				end
				
				orientUpRightRight: begin
					if(moveForward) begin
						carAddress <= orientUpRightRight * 1024;
						currentOrientation <= orientUpRightRight;
						backgroundAddress <= backgroundAddress + (-(320 * (pixelsToMove - 1)) + pixelsToMove);
						currentXPosition <= currentXPosition + pixelsToMove;
						currentYPosition <= currentYPosition - (pixelsToMove - 1);
					end
					else if(moveRight) begin
						carAddress <= orientRight * 1024;
						currentOrientation <= orientRight;
					end
					else if (moveLeft) begin
						carAddress <= orientUpRight * 1024;
						currentOrientation <= orientUpRight;
					end
				end

				orientUpRight: begin
					if(moveForward) begin
						carAddress <= orientUpRight * 1024;
						currentOrientation <= orientUpRight;
						backgroundAddress <= backgroundAddress + (-(320 * pixelsToMove) + pixelsToMove);
						currentXPosition <= currentXPosition + pixelsToMove;
						currentYPosition <= currentYPosition - pixelsToMove;
					end
					else if(moveRight) begin
						carAddress <= orientUpRightRight * 1024;
						currentOrientation <= orientUpRightRight;
					end
					else if(moveLeft) begin
						carAddress <= orientUpUpRight * 1024;
						currentOrientation <= orientUpUpRight;
					end
				end
				
				orientUpUpRight: begin
					if(moveForward) begin
						carAddress <= orientUpUpRight * 1024;
						currentOrientation <= orientUpUpRight;
						backgroundAddress <= backgroundAddress + (-(320 * pixelsToMove) + (pixelsToMove - 1));
						currentXPosition <= currentXPosition + (pixelsToMove - 1);
						currentYPosition <= currentYPosition - pixelsToMove;
					end
					else if(moveRight) begin
						carAddress <= orientUpRight * 1024;
						currentOrientation <= orientUpRight;
					end
					else if(moveLeft) begin
						carAddress <= orientUp * 1024;
						currentOrientation <= orientUp;
					end
				end

				orientUp: begin
					if(moveForward) begin
						carAddress <= orientUp * 1024;
						currentOrientation <= orientUp;
						backgroundAddress <= backgroundAddress - (320 * pixelsToMove);
						currentYPosition <= currentYPosition - pixelsToMove;
					end

					else if(moveRight) begin
						carAddress <= orientUpUpRight * 1024;
						currentOrientation <= orientUpUpRight;
					end

					else if(moveLeft) begin
						carAddress <= orientUpUpLeft * 1024;
						currentOrientation <= orientUpUpLeft;
					end
				end
				
				orientUpUpLeft: begin
					if(moveForward) begin
						carAddress <= orientUpUpLeft * 1024;
						currentOrientation <= orientUpUpLeft;
						backgroundAddress <= backgroundAddress + (-(320 * pixelsToMove) - (pixelsToMove - 1));
						currentXPosition <= currentXPosition - (pixelsToMove - 1);
						currentYPosition <= currentYPosition - pixelsToMove;
					end
					else if(moveRight) begin
						carAddress <= orientUp * 1024;
						currentOrientation <= orientUp;
					end
					else if(moveLeft) begin
						carAddress <= orientUpLeft * 1024;
						currentOrientation <= orientUpLeft;
					end
				end

				orientUpLeft: begin
					if(moveForward) begin
						carAddress <= orientUpLeft * 1024;
						currentOrientation <= orientUpLeft;
						backgroundAddress <= backgroundAddress + (-(320 * pixelsToMove) - pixelsToMove);
						currentXPosition <= currentXPosition - pixelsToMove;
						currentYPosition <= currentYPosition - pixelsToMove;
					end
					else if(moveRight) begin
						carAddress <= orientUpUpLeft * 1024;
						currentOrientation <= orientUpUpLeft;
					end
					else if(moveLeft) begin
						carAddress <= orientUpLeftLeft * 1024;
						currentOrientation <= orientUpLeftLeft;
					end
				end
				
				orientUpLeftLeft: begin
					if(moveForward) begin
						carAddress <= orientUpLeftLeft * 1024;
						currentOrientation <= orientUpLeftLeft;
						backgroundAddress <= backgroundAddress + (-(320 * (pixelsToMove - 1)) - pixelsToMove);
						currentXPosition <= currentXPosition - pixelsToMove;
						currentYPosition <= currentYPosition - (pixelsToMove - 1);
					end
					else if(moveRight) begin
						carAddress <= orientUpLeft * 1024;
						currentOrientation <= orientUpLeft;
					end
					else if(moveLeft) begin
						carAddress <= orientLeft * 1024;
						currentOrientation <= orientLeft;
					end
				end
			
				orientLeft: begin
					if(moveForward) begin
						carAddress <= orientLeft * 1024;
						currentOrientation <= orientLeft;
						backgroundAddress <= backgroundAddress - pixelsToMove;
						currentXPosition <= currentXPosition - pixelsToMove;
					end
					else if(moveRight) begin
						carAddress <= orientUpLeftLeft * 1024;
						currentOrientation <= orientUpLeftLeft;
					end
					else if(moveLeft) begin
						carAddress <= orientDownLeftLeft * 1024;
						currentOrientation <= orientDownLeftLeft;
					end
				end
				
				orientDownLeftLeft: begin
					if(moveForward) begin
						carAddress <= orientDownLeftLeft * 1024;
						currentOrientation <= orientDownLeftLeft;
						backgroundAddress <= backgroundAddress + (320 * (pixelsToMove - 1) - pixelsToMove);
						currentXPosition <= currentXPosition - pixelsToMove;
						currentYPosition <= currentYPosition + (pixelsToMove - 1);
					end
					else if(moveRight) begin
						carAddress <= orientLeft * 1024;
						currentOrientation <= orientLeft;
					end
					else if(moveLeft) begin
						carAddress <= orientDownLeft * 1024;
						currentOrientation <= orientDownLeft;
					end
				end
				
				orientDownLeft: begin
					if(moveForward) begin
						carAddress <= orientDownLeft * 1024;
						currentOrientation <= orientDownLeft;
						backgroundAddress <= backgroundAddress + ((320 * pixelsToMove) - pixelsToMove);
						currentXPosition <= currentXPosition - pixelsToMove;
						currentYPosition <= currentYPosition + pixelsToMove;
					end
					else if(moveRight) begin
						carAddress <= orientDownLeftLeft * 1024;
						currentOrientation <= orientDownLeftLeft;
					end
					else if(moveLeft) begin
						carAddress <= orientDownDownLeft * 1024;
						currentOrientation <= orientDownDownLeft;
					end
				end
				
				orientDownDownLeft: begin
					if(moveForward) begin
						carAddress <= orientDownDownLeft * 1024;
						currentOrientation <= orientDownDownLeft;
						backgroundAddress <= backgroundAddress + (320 * pixelsToMove - (pixelsToMove - 1));
						currentXPosition <= currentXPosition - (pixelsToMove - 1);
						currentYPosition <= currentYPosition + pixelsToMove;
					end
					else if(moveRight) begin
						carAddress <= orientDownLeft * 1024;
						currentOrientation <= orientDownLeft;
					end
					else if(moveLeft) begin
						carAddress <= orientDown * 1024;
						currentOrientation <= orientDown;
					end
				end
				
				orientDown: begin
					if(moveForward) begin
						carAddress <= orientDown * 1024;
						currentOrientation <= orientDown;
						backgroundAddress <= backgroundAddress + (320 * pixelsToMove);
						currentYPosition <= currentYPosition + pixelsToMove;
					end
					else if(moveRight) begin
						carAddress <= orientDownDownLeft * 1024;
						currentOrientation <= orientDownDownLeft;
					end
					else if(moveLeft) begin
						carAddress <= orientDownDownRight * 1024;
						currentOrientation <= orientDownDownRight;
					end
				end
				
				orientDownDownRight: begin
					if(moveForward) begin
						carAddress <= orientDownDownRight * 1024;
						currentOrientation <= orientDownDownRight;
						backgroundAddress <= backgroundAddress + (320 * pixelsToMove + (pixelsToMove - 1));
						currentXPosition <= currentXPosition + (pixelsToMove - 1);
						currentYPosition <= currentYPosition + pixelsToMove;
					end
					else if(moveRight) begin
						carAddress <= orientDown * 1024;
						currentOrientation <= orientDown;
					end
					else if(moveLeft) begin
						carAddress <= orientDownRight * 1024;
						currentOrientation <= orientDownRight;
					end
				end
				
				orientDownRight: begin
					if(moveForward) begin
						carAddress <= orientDownRight * 1024;
						currentOrientation <= orientDownRight;
						backgroundAddress <= backgroundAddress + ((320 * pixelsToMove) + pixelsToMove);
						currentXPosition <= currentXPosition + pixelsToMove;
						currentYPosition <= currentYPosition + pixelsToMove;
					end
					else if(moveRight) begin
						carAddress <= orientDownDownRight * 1024;
						currentOrientation <= orientDownDownRight;
					end
					else if(moveLeft) begin
						carAddress <= orientDownRightRight * 1024;
						currentOrientation <= orientDownRightRight;
					end
				end
				
				orientDownRightRight: begin
					if(moveForward) begin
						carAddress <= orientDownRightRight * 1024;
						currentOrientation <= orientDownRightRight;
						backgroundAddress <= backgroundAddress + (320 * (pixelsToMove - 1) + pixelsToMove);
						currentXPosition <= currentXPosition + pixelsToMove;
						currentYPosition <= currentYPosition + (pixelsToMove - 1);
					end
					else if(moveRight) begin
						carAddress <= orientDownRight * 1024;
						currentOrientation <= orientDownRight;
					end
					else if(moveLeft) begin
						carAddress <= orientRight * 1024;
						currentOrientation <= orientRight;
					end
				end
				
			endcase
		end
		
		if(currentXPosition == 9'd120 && currentYPosition > 8'd183 &&
		   currentYPosition < 8'd206)
			pastStartLine <= 1'b1;
		
		//DRAWING WIN SCREEN
		if(!FinishedRace && pastStartLine && currentXPosition == 9'd126 &&
		    currentYPosition > 8'd183 && currentYPosition < 8'd206) begin// numbers for y may change after testing on board
				FinishedRace <= 1'b1;
				currentXPosition <= 9'd0;
				currentYPosition <= 8'd0;
				xCount <= 9'd0;
				yCount <= 8'd0;
		end
	end
			
endmodule	