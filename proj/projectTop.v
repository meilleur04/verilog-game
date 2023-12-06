module projectTop(
	input Clock, Resetn, simReset, Start, moveForward, moveRight, moveLeft,
	output reg[8:0] xOut,
	output reg[7:0] yOut,
	output reg[7:0] secondsPassed,
	output[5:0] colourOut,
	output reg plotOut);
	
	wire set_reset_signals, start_race, draw_background, draw_car, draw_over_car, move, draw_win_screen, draw_start_screen;
	wire DoneDrawCar, DoneDrawBackground, DoneDrawOverCar, FinishedRace, DoneDrawWinScreen, DoneDrawStartScreen;
	
	wire[19:0] OneFrameCounter;
	wire Enable1Frame;
	
	
	DelayCounter DC0(
		.countDownNum(20'd833_334), // SET TO 1 FOR SIMULATION PURPOSES
		.Clock(Clock),
		.simReset(simReset),
		.RDOut(OneFrameCounter));
	
	assign Enable1Frame = (OneFrameCounter == 20'd0) ? 1'b1 : 1'b0;
	
	wire plotWire;
	
	control C0(
		.Clock(Clock),
		.Resetn(Resetn),
		.Enable1Frame(Enable1Frame),
		.start(Start),
		.forward(moveForward),
		.right(moveRight),
		.left(moveLeft),
		.DoneDrawBackground(DoneDrawBackground),
		.DoneDrawCar(DoneDrawCar),
		.DoneDrawOverCar(DoneDrawOverCar),
		.FinishedRace(FinishedRace),
		.set_reset_signals(set_reset_signals),
		.start_race(start_race),
		.draw_background(draw_background),
		.draw_car(draw_car),
		.draw_over_car(draw_over_car),
		.move(move),
		.plot(plotWire),
		.DoneDrawStartScreen(DoneDrawStartScreen), 
		.DoneDrawWinScreen(DoneDrawWinScreen),
		.draw_start_screen(draw_start_screen),
		.draw_win_screen(draw_win_screen));
		
	wire[8:0] xWire;
	wire[7:0] yWire;
		
	datapath D0(
		.Clock(Clock),
		.Resetn(Resetn),
		.moveForward(moveForward),
		.moveRight(moveRight),
		.moveLeft(moveLeft),
		.set_reset_signals(set_reset_signals),
		.start_race(start_race),
		.draw_background(draw_background),
		.draw_car(draw_car),
		.draw_over_car(draw_over_car),
		.move(move),
		.DoneDrawBackground(DoneDrawBackground),
		.DoneDrawCar(DoneDrawCar),
		.DoneDrawOverCar(DoneDrawOverCar),
		.FinishedRace(FinishedRace),
		.colourOut(colourOut),
		.xOut(xWire),
		.yOut(yWire),
		.DoneDrawStartScreen(DoneDrawStartScreen), 
		.DoneDrawWinScreen(DoneDrawWinScreen),
		.draw_start_screen(draw_start_screen),
		.draw_win_screen(draw_win_screen));
	
	always@(posedge Clock) begin
		xOut <= xWire;
		yOut <= yWire;
		plotOut <= plotWire;
	end
	
	wire[27:0] secondsCount;
	wire Enable1Second;
	
	SecondsCounter S0(
		.Clock(Clock),
		.simReset(simReset),
		.countDownNum(28'd49_999_999),
		.RDOut(secondsCount));
		
	assign Enable1Second = (secondsCount == 28'd0) ? 1'b1 : 1'b0;
	
	always@(posedge Clock) begin
		if(Enable1Second) begin
			if(!FinishedRace) secondsPassed <= secondsPassed + 8'd1;
			else secondsPassed <= secondsPassed;
		end
		else begin
			if(!Resetn || !Start) secondsPassed <= 8'd0;
			else secondsPassed <= secondsPassed;
		end
	end

endmodule
