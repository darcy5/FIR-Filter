import numpy as np
import matplotlib.pyplot as plt

# 1. Load input data from hex file
with open('Input_Data.txt', 'r') as f:
    hex_values = f.read().split()

# Convert hex to signed 16-bit integers
def hex_to_int16(h):
    val = int(h, 16)
    if val >= 0x8000:
        val -= 0x10000
    return val

input_ints = np.array([hex_to_int16(h) for h in hex_values], dtype=np.int16)

# 2. Convert coefficients to Q4.12 format
coefficients_float = [-0.0841, -0.0567, 0.1826, 0.4086, 0.4086, 0.1826, -0.0567, -0.0841]
coefficients_fixed = [int(round(c * (2**12))) for c in coefficients_float]  # Q4.12 scaling
coefficients_fixed = np.array(coefficients_fixed, dtype=np.int16)

# 3. FIR filtering with fixed-point simulation
output_fixed = []
for n in range(len(input_ints)):
    acc = 0
    for k in range(8):
        if n - k >= 0:
            acc += int(input_ints[n - k]) * int(coefficients_fixed[k])
    # After accumulation, shift right by 12 bits to simulate Q4.12 output
    acc_shifted = acc >> 12
    # Saturate to int16 range
    acc_shifted = max(min(acc_shifted, 32767), -32768)
    output_fixed.append(acc_shifted)

output_fixed = np.array(output_fixed, dtype=np.int16)

# 4. Save output to a text file
np.savetxt('FIR_Output.txt', output_fixed, fmt='%d')

# 5. Plot Input and Output
plt.figure(figsize=(10,5))
plt.plot(input_ints, label='Input Signal', color='blue')
plt.plot(output_fixed, label='FIR Output Signal', color='red')
plt.title('8-Tap FIR Filter (Q4.12 Fixed-Point)')
plt.xlabel('Sample Index')
plt.ylabel('Amplitude')
plt.grid(True)
plt.legend()
plt.show()
