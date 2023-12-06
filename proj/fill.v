module fill
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		KEY,
		SW,
		HEX0, HEX1,
		PS2_CLK,
		PS2_DAT,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B ,
  						//	VGA Blue[9:0]
	AUD_ADCDAT,
	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,
	FPGA_I2C_SDAT,
	// Outputs
	AUD_XCK,
	AUD_DACDAT,
	FPGA_I2C_SCLK);

	input			CLOCK_50;				//	50 MHz
	input	 [3:0] KEY;
	input  [9:0] SW;
	output [0:6] HEX0, HEX1;
	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[9:0]
	output	[7:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[9:0]
	
	input				AUD_ADCDAT;

// Bidirectionals
inout				AUD_BCLK;
inout				AUD_ADCLRCK;
inout				AUD_DACLRCK;

inout				FPGA_I2C_SDAT;

// Outputs
output				AUD_XCK;
output				AUD_DACDAT;

output				FPGA_I2C_SCLK;
	wire resetn;
	assign resetn = KEY[3];
	
	inout				PS2_CLK;
	inout				PS2_DAT;
	wire 				signalStraight, signalRight, signalLeft;
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.

	wire [5:0] colour;
	wire [8:0] x;
	wire [7:0] y;
	wire writeEn;
	wire[7:0] secondsPassed;
	
	audio2 ao(
	// Inputs
	CLOCK_50,
	KEY,
	AUD_ADCDAT,
	// Bidirectionals
	AUD_BCLK,
	AUD_ADCLRCK,
	AUD_DACLRCK,
	FPGA_I2C_SDAT,
	// Outputs
	AUD_XCK,
	AUD_DACDAT,
	FPGA_I2C_SCLK,
	SW
);

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "320x240";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 2;
		defparam VGA.BACKGROUND_IMAGE = "track.mif";
			
		projectTop P0(
			.Clock(CLOCK_50),
			.Resetn(resetn),
			.simReset(1'b0),
			.Start(SW[9]),
			.moveForward(signalStraight),
			.moveRight(signalRight),
			.moveLeft(signalLeft),
			.xOut(x),
			.yOut(y),
			.secondsPassed(secondsPassed),
			.colourOut(colour),
			.plotOut(writeEn));
		
		PS2_Call ps2call(
			// Inputs
			CLOCK_50,
			SW[9],

			// Bidirectionals
			PS2_CLK,
			PS2_DAT,
	
			// Outputs
			signalStraight, signalRight, signalLeft);
	
		hex7seg hex0(.c(secondsPassed[3:0]), .led(HEX0));
		hex7seg hex1(.c(secondsPassed[7:4]), .led(HEX1));
	
endmodule