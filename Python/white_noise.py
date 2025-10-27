import numpy as np

count = 500
np.random.seed(0)
noise = np.random.normal(0, 1, count)
noise = noise / np.max(np.abs(noise)) * 5

with open("noise.txt", "w") as file:
    for value in noise:
        file.write(f"{round(value, 1)}\n")