// Testbench for the 8-tap FIR Filter
module fir_tb;

	// Clock and Reset signals
	reg clk = 0;                            // Clock initialized to 0
	reg rst = 1;                            // Reset initially active

	// Input and output to the FIR filter
	reg signed [15:0] x_in;                 // 16-bit signed input sample
	wire signed [15:0] y_out;              // 16-bit signed output sample

	// File descriptors and loop variable
	integer input_file, output_file, i;     // Input/output file handlers and loop index

	// Input format conversion
	reg [15:0] hex_in;                      // Holds hexadecimal input from file
	real float_in, float_out;              // Floating-point versions of input/output
	real golden_out, prev_golden_out;     // Expected output from golden reference
	real error;                            // Error between DUT and golden output

	// Floating-point arrays for coefficients and delay-line samples
	real coeffs[0:7];                      // FIR filter coefficients
	real samples[0:7];                     // Delay-line for past input samples

	// Instantiate the FIR filter unit under test (UUT)
	fir_filter uut (
		.clk(clk),
		.rst(rst),
		.x_in(x_in),
		.y_out(y_out)
	);

	// Generate clock signal with a period of 10 time units (toggle every 5 units)
	always #5 clk = ~clk;

	// Initial block: simulation starts here
	initial begin
		// Initialize the FIR coefficients
		coeffs[0] = -0.0841; coeffs[1] = -0.0567; coeffs[2] = 0.1826; coeffs[3] = 0.4086;
		coeffs[4] = 0.4086;  coeffs[5] = 0.1826;  coeffs[6] = -0.0567; coeffs[7] = -0.0841;

		// Initialize all previous input samples to 0.0
		for (i = 0; i < 8; i = i + 1)
			samples[i] = 0.0;

		// Open the input file for reading and output file for writing
		input_file = $fopen("Input_Data.txt", "r");
		output_file = $fopen("Output_Data.txt", "w");

		// Deassert reset after 10 time units to start processing
		#10 rst = 0;

		// Initialize the golden output for the first comparison
		prev_golden_out = 0.0;

		// Loop through 256 input samples
		for (i = 0; i < 256; i = i + 1) begin
			// Read a hexadecimal input sample from file
			$fscanf(input_file, "%h", hex_in);
			x_in = hex_in;  // Apply it to the DUT

			// Convert input to floating-point (Q4.12 to float)
			float_in = $itor($signed(hex_in)) / 4096.0;

			// Shift previous input samples for delay line
			samples[7] = samples[6];
			samples[6] = samples[5];
			samples[5] = samples[4];
			samples[4] = samples[3];
			samples[3] = samples[2];
			samples[2] = samples[1];
			samples[1] = samples[0];
			samples[0] = float_in;

			// Calculate expected golden output using FIR formula
			golden_out = 0.0;
			for (int j = 0; j < 8; j = j + 1)
				golden_out += coeffs[j] * samples[j];

			#10; // Wait one clock cycle to get output from DUT

			// Convert DUT output to float
			float_out = $itor(y_out) / 4096.0;

			// Compute the error between DUT and previous golden output
			error = float_out - prev_golden_out;

			// Log DUT output to file and display on console
			$fwrite(output_file, "%f\n", float_out);
			$display("Sample %0d: DUT = %f, Golden = %f, Error = %f", i, float_out, prev_golden_out, error);

			// Update golden output for next comparison
			prev_golden_out = golden_out;
		end

		// Close files after processing
		$fclose(input_file);
		$fclose(output_file);

		// Stop simulation
		$stop;
	end

endmodule
