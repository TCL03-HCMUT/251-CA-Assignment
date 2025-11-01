import numpy as np
import matplotlib.pyplot as plt
import argparse

def read_signal(path):
    with open(path, "r") as f:
        return np.array(list(map(float, f.readlines()[0].split())))
    
parser = argparse.ArgumentParser(description="Barebones Wiener filter (pure Python)")
parser.add_argument("--input", default="input.txt")
parser.add_argument("--desired", default="desired.txt")
parser.add_argument("--order", type=int, default=10)
parser.add_argument("--output", default="wiener_output.txt")
args = parser.parse_args()

desired = read_signal(args.desired)
wiener_output = read_signal(args.output)
input_signal = read_signal(args.input)

plt.plot(input_signal, color = "b", linestyle = "dashed", label = "Input values")
plt.plot(desired, color = "r", linestyle = "solid", label = "Desired values")
plt.plot(wiener_output, color = "g", linestyle = "solid", label = "Output")

plt.legend()
plt.show()