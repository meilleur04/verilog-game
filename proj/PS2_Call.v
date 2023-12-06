module PS2_Call (
	input	CLOCK_50, input Resetn, inout	PS2_CLK, inout	PS2_DAT, output wire signalStraight, output wire signalRight, output wire signalLeft
);

/*****************************************************************************
 *                           Parameter Declarations                          *
 *****************************************************************************/

 inputs detector(.CLOCK_50(CLOCK_50),
					  .signalStraight(signalStraight),
					  .signalLeft(signalLeft),
					  .signalRight(signalRight),
					  .ps2_key_pressed(ps2_key_pressed),
					  .ps2_key_data(last_data_received),
					  .Resetn(Resetn));
	
	
/*****************************************************************************
 *                             Port Declarations                             *
 *****************************************************************************/

// Inputs
	

	/*****************************************************************************
	 *                 Internal Wires and Registers Declarations                 *
	 *****************************************************************************/

	// Internal Wires
	wire		[7:0]	ps2_key_data;
	wire				ps2_key_pressed;

	// Internal Registers
	reg			[7:0]	last_data_received;
	
	// State Machine Registers

	/*****************************************************************************
	 *                             Sequential Logic                              *
	 *****************************************************************************/

	always @(posedge CLOCK_50)
	begin
		if(!Resetn)
			last_data_received <= 8'h00;
		else if(ps2_key_pressed == 1'b1)
			last_data_received <= ps2_key_data;
	end


	/*****************************************************************************
	 *                              Internal Modules                             *
	 *****************************************************************************/

	PS2_Controller PS2 (
		// Inputs
		.CLOCK_50				(CLOCK_50),
		.reset				   (!Resetn),

		// Bidirectionals
		.PS2_CLK			(PS2_CLK),
		.PS2_DAT			(PS2_DAT),

		// Outputs
		.received_data		(ps2_key_data),
		.received_data_en	(ps2_key_pressed)
	);
	
endmodule


module inputs(CLOCK_50, signalStraight, signalLeft, signalRight, ps2_key_pressed, ps2_key_data, Resetn);
 
 input CLOCK_50,  ps2_key_pressed, Resetn;
 input [7:0] ps2_key_data;
 output reg signalStraight, signalLeft, signalRight;
 

 reg[3:0] current_state, next_state;
 
	
	localparam  E0 = 4'd0,
				F0 = 4'd1, 
				WAIT = 4'd2,
				LEFT = 4'd3,
				RIGHT = 4'd4,
				STRAIGHT = 4'd5,
				LEFT_BREAK = 4'd6,
				RIGHT_BREAK = 4'd7,
				STRAIGHT_BREAK = 4'd8;
    
    // Next state logic aka our state table
    always@(*)
    begin: state_table 
		case (current_state)
			WAIT: begin
				if (ps2_key_data == 8'hE0 && ps2_key_pressed) next_state = E0;
				else if(ps2_key_data == 8'hF0 && ps2_key_pressed) next_state = F0;
				else next_state = WAIT;
			end
			E0: begin
				if(ps2_key_data == 8'h75) next_state = STRAIGHT;
				else if(ps2_key_data == 8'h6B) next_state = LEFT;
				else if(ps2_key_data == 8'h74) next_state = RIGHT;
				else if (ps2_key_data == 8'hF0) next_state = F0;
				else next_state = WAIT;
			end
			F0: begin
				// represents transition from E0 to F0 or from movement to wait state
				if(ps2_key_data == 8'h75) next_state = STRAIGHT_BREAK;
				else if(ps2_key_data == 8'h6B) next_state = LEFT_BREAK;
				else if(ps2_key_data == 8'h74) next_state = RIGHT_BREAK;
				else next_state = WAIT;
			end
			LEFT: next_state = WAIT;
			RIGHT: next_state = WAIT;
			STRAIGHT: next_state = WAIT;
			LEFT_BREAK: next_state = WAIT;
			RIGHT_BREAK: next_state = WAIT;
			STRAIGHT_BREAK: next_state = WAIT;
			default: next_state = WAIT;
		endcase
	end
	
	
	
	always @(posedge CLOCK_50) begin
	
		if (!Resetn) begin
			signalStraight <= 1'b0;
			signalLeft <= 1'b0;
			signalRight <= 1'b0;
		end
		else if (current_state == STRAIGHT) signalStraight <= 1'b1;
		else if(current_state == LEFT) signalLeft <= 1'b1;
		else if(current_state == RIGHT) signalRight <= 1'b1;
		else if (current_state == STRAIGHT_BREAK) signalStraight <= 1'b0;
		else if (current_state == LEFT_BREAK) signalLeft <= 1'b0;
		else if (current_state == RIGHT_BREAK) signalRight <= 1'b0;

	end
		
	always@(posedge CLOCK_50)
    begin: state_FFs
        if(!Resetn)
           current_state <= WAIT;
        else
            current_state <= next_state;
    end // state_FFS
	 
endmodule
