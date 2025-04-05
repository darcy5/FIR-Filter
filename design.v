// FIR Filter Module (8-Tap, Q4.12 Fixed Point)
module fir_filter (
	input clk,                           // Clock signal
	input rst,                           // Asynchronous reset signal
	input signed [15:0] x_in,            // 16-bit signed input sample (Q4.12 format)
	output reg signed [15:0] y_out       // 16-bit signed output sample (Q4.12 format)
);

	// Registers to store the last 8 input samples (delay line)
	reg signed [15:0] x_reg[0:7];

	// 28-bit accumulator to hold intermediate sum during MAC operations
	reg signed [27:0] acc;

	// Loop variable for iteration
	integer i;

	// Filter coefficients in Q4.12 fixed-point format
	// Converted as: value × 2^12, then rounded to integer
	parameter signed [15:0] COEFF[0:7] = {
		-345,   // a0 = -0.0841 * 2^12 ≈ -345
		-232,   // a1 = -0.0567 * 2^12 ≈ -232
		 748,   // a2 =  0.1826 * 2^12 ≈ 748
		1674,   // a3 =  0.4086 * 2^12 ≈ 1674
		1674,   // a4 =  0.4086 * 2^12 ≈ 1674
		 748,   // a5 =  0.1826 * 2^12 ≈ 748
		-232,   // a6 = -0.0567 * 2^12 ≈ -232
		-345    // a7 = -0.0841 * 2^12 ≈ -345
	};

	// Main processing logic
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			// Reset all input registers and output
			for (i = 0; i < 8; i = i + 1)
				x_reg[i] <= 0;
			y_out <= 0;
			acc <= 0;
		end else begin
			// Shift previous samples right
			for (i = 7; i > 0; i = i - 1)
				x_reg[i] <= x_reg[i - 1];

			// Store the new input sample
			x_reg[0] <= x_in;

			// Clear accumulator
			acc = 0;

			// Multiply each input sample with its coefficient and accumulate
			for (i = 0; i < 8; i = i + 1)
				acc = acc + x_reg[i] * COEFF[i];

			// Assign the scaled result to output (Q4.12 format)
			y_out <= acc[27:12];
		end
	end

endmodule
