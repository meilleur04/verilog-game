module control(
	input Clock, Resetn, Enable1Frame, start, forward, right, left,
	input DoneDrawBackground, DoneDrawCar, DoneDrawOverCar, DoneDrawStartScreen, DoneDrawWinScreen, FinishedRace, 
	output reg set_reset_signals, start_race, draw_background, draw_car, draw_over_car, draw_start_screen, draw_win_screen, move, plot);
	
	reg[3:0] current_state, next_state;

	
	localparam  	DRAW_START_SCREEN = 0,
					START_RACE		  = 1,
					SET_RESET_SIGNALS = 2,
					DRAW_BACKGROUND   = 3,
					DRAW_CAR          = 4,
					WAIT_FOR_MOVE     = 5,
					DRAW_OVER_CAR     = 6,
					MOVE_FORWARD 	  = 7,
					MOVE_LEFT_RIGHT   = 8,
					WAIT_LEFT_RIGHT   = 9,
					DRAW_EXPLOSION    = 10,
					DRAW_WIN_SCREEN	  = 11;
    
    always@(*)
    begin: state_table 
		case (current_state)
			DRAW_START_SCREEN: begin
				if(DoneDrawStartScreen) begin
					if(!start && FinishedRace) next_state = DRAW_START_SCREEN;
					else if(start) next_state = START_RACE;
					else next_state = DRAW_START_SCREEN;
				end
				else next_state = DRAW_START_SCREEN;
			end
			START_RACE: next_state = DRAW_BACKGROUND;
			SET_RESET_SIGNALS: next_state = DRAW_START_SCREEN;
			DRAW_BACKGROUND: next_state = DoneDrawBackground ? DRAW_CAR : DRAW_BACKGROUND;
			DRAW_CAR: begin
				if(DoneDrawCar) begin
					if(!start) next_state = SET_RESET_SIGNALS;
					else if(FinishedRace) next_state = DRAW_WIN_SCREEN;
					else if(forward == 1'b1 && Enable1Frame) next_state = DRAW_OVER_CAR;
					else if(left == 1'b1 || right == 1'b1) next_state = WAIT_LEFT_RIGHT;
					else next_state = WAIT_FOR_MOVE;
				end
				else next_state = DRAW_CAR;
			end
			WAIT_FOR_MOVE: begin
				if(forward == 1'b1 && Enable1Frame) next_state = DRAW_OVER_CAR;
				else if(left == 1'b1 || right == 1'b1) next_state = DRAW_OVER_CAR;
				else next_state = WAIT_FOR_MOVE;
			end
			DRAW_OVER_CAR: begin
				if(DoneDrawOverCar) begin
					if(forward == 1'b1) next_state = MOVE_FORWARD;
					else if(left == 1'b1 || right == 1'b1) next_state = MOVE_LEFT_RIGHT;
					else next_state = DRAW_CAR;
				end
				else next_state = DRAW_OVER_CAR;
			end
			MOVE_FORWARD: next_state = DRAW_CAR;
			MOVE_LEFT_RIGHT: next_state = DRAW_CAR;
			WAIT_LEFT_RIGHT: next_state = (left == 1'b1 || right == 1'b1) ? WAIT_LEFT_RIGHT : WAIT_FOR_MOVE;
			DRAW_WIN_SCREEN: begin
				if(DoneDrawWinScreen) begin
					if(start) next_state = DRAW_WIN_SCREEN;
					else next_state = SET_RESET_SIGNALS;
				end
				else next_state = DRAW_WIN_SCREEN;
			end
			default: next_state = SET_RESET_SIGNALS;
		endcase
    end 

    always @(*)
    begin: enable_signals
	 
		set_reset_signals = 1'b0;
		start_race = 1'b0;
		draw_background = 1'b0;
		draw_car = 1'b0;
		draw_over_car = 1'b0;
		draw_start_screen = 1'b0;
		draw_win_screen = 1'b0;
		move = 1'b0;
		plot = 1'b0;
	 
        case (current_state)
			DRAW_START_SCREEN: begin
				draw_start_screen = 1'b1;
				plot = 1'b1;
			end
			SET_RESET_SIGNALS: set_reset_signals = 1'b1;
			DRAW_BACKGROUND: begin
				draw_background = 1'b1;
				plot = 1'b1;
			end
			START_RACE: start_race = 1'b1;
			DRAW_CAR: begin
				if(DoneDrawCar) plot = 1'b0;
				else begin
					draw_car = 1'b1;
					plot = 1'b1;
				end
			end
			DRAW_OVER_CAR: begin
				if(DoneDrawOverCar) plot = 1'b0;
				else begin
					draw_over_car = 1'b1;
					plot = 1'b1;
				end
			end
			MOVE_FORWARD: move = 1'b1;
			MOVE_LEFT_RIGHT: move = 1'b1;
			DRAW_WIN_SCREEN: begin
				draw_win_screen = 1'b1;
				plot = 1'b1;
			end
        endcase
    end 
   
  
    always@(posedge Clock)
    begin: state_FFs
        if(!Resetn)
           current_state <= SET_RESET_SIGNALS;
        else
            current_state <= next_state;
    end 
	 
endmodule