# **FIR Filter Design and Verification**

## 🔍 **Objective:**

This experiment aims to design and verify an 8-tap Finite Impulse Response (FIR) filter using Verilog. The filter operates on fixed-point Q4.12 format (16-bit signed data with 4 integer bits and 12 fractional bits) and uses the following filter coefficients:
[-0.0841, -0.0567, 0.1826, 0.4086, 0.4086, 0.1826, -0.0567, -0.0841]

=========================================================

## ⚙️ **FIR Filter Functionality**

Using the given coefficients, the FIR filter performs a convolution over 8 previous samples. 
On each clock cycle:
1) It shifts the new input sample into a shift register.
2) It calculates a dot product between stored samples and coefficients.
3) The result is scaled appropriately and output in fixed-point Q4.12 format.
4) The filter includes a reset input to initialize all internal states.

=========================================================

## 🧪 **Testbench Functionality**

A Verilog testbench is used to verify the FIR filter:
1) Reads hexadecimal input data from Input_Data.txt.
2) Converts each input sample to floating-point and stores the recent 8 samples.
3) Compute the golden output using floating-point arithmetic.
4) Feeds the sample to the DUT (Device Under Test).
5) Waits for one clock cycle (pipeline latency).
6) Converts DUT output back to float and compares it with the golden output.
7) Computes and displays the error.
8) Logs results to Output_Data.txt.

=========================================================

## 🌟 **Why Use a Golden Reference?**

1) The golden reference is a high-precision floating-point model of the filter implemented in the testbench. It helps:
2) Validate the correctness of the fixed-point hardware design.
3) Ensure filtering behavior matches the expected theoretical model.
4) Identify any mismatch or inaccuracy introduced by fixed-point operations.

=========================================================

## 📉 **Error Calculation**

The error is computed as: error = DUT_output - golden_output

This helps analyze how closely the hardware matches the software reference. Small errors are expected due to quantization, fixed-point truncation, or rounding, but large errors may indicate design flaws or misconfigurations.

