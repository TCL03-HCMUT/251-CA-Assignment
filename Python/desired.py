import numpy as np

# np.random.seed(0)
result = [2*np.sin(i) + 3 * np.cos(i) for i in range(10)]

with open("desired.txt", "w") as file:
    for value in result:
        file.write(f"{round(value, 1)} ")