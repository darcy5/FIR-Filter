import matplotlib.pyplot as plt

# --- Convert hex to signed 16-bit integer ---
def hex_to_signed(val):
    if val >= 0x8000:
        return val - 0x10000
    return val

# --- Load and convert Input_Data.txt (hex Q4.12) ---
with open("Input_Data.txt", "r") as f:
    hex_values = f.read().split()

input_q412 = []
for hex_val in hex_values:
    signed_int = hex_to_signed(int(hex_val, 16))
    float_val = signed_int / 4096.0  # Convert Q4.12 fixed-point to float
    input_q412.append(float_val)

# --- Load Output_Data_fromVerilog.txt (already floats) ---
with open("Output_Data_fromVerilog.txt", "r") as f:
    output_values = [float(line.strip()) for line in f.readlines()]

# --- Plot ---
plt.figure(figsize=(12, 6))
plt.plot(input_q412, label="Input Signal (Q4.12)", marker='o', markersize=3, linestyle='-')
plt.plot(output_values, label="Output Signal (Filtered)", marker='x', markersize=3, linestyle='--')
plt.title("FIR Filter: Input vs Output")
plt.xlabel("Sample Index")
plt.ylabel("Amplitude")
plt.legend()
plt.grid(True)
plt.tight_layout()
plt.show()
