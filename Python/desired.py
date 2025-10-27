import numpy as np

# np.random.seed(0)
result = [20 * np.sin(i * 0.1) + 10 * np.cos(i * 0.2) for i in range(500)]

with open("desired.txt", "w") as file:
    for value in result:
        file.write(f"{round(value, 1)}\n")