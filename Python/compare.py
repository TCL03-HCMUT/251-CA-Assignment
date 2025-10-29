import numpy as np
import matplotlib.pyplot as plt

def read_signal(path):
    with open(path, "r") as f:
        return np.array(list(map(float, f.readlines()[0].split())))
    

desired = read_signal("desired.txt")
wiener_output = read_signal("wiener_output.txt")
input_signal = read_signal("input1.txt")

plt.plot(input_signal, color = "b", linestyle = "dashed", label = "Input values")
plt.plot(desired, color = "r", linestyle = "solid", label = "Desired values")
plt.plot(wiener_output, color = "g", linestyle = "solid", label = "Output")

plt.legend()
plt.show()