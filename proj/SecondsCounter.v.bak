module DelayCounter(
	input Clock, simReset,
	input[19:0] countDownNum,
	output reg[19:0] RDOut);
	
	always @ (posedge Clock)
		begin
			if (simReset)
				RDOut <= 20'd0;
			else if (RDOut == 20'd0)
				RDOut <= countDownNum;
			else
				RDOut <= RDOut - 20'd1;
		end

endmodule