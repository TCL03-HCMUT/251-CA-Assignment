with open("desired.txt", "r") as file:
    desired = file.readlines()
with open("noise.txt", "r") as file:
    noise = file.readlines()
    
output = [float(desired_val) + float(noise_val) for desired_val, noise_val in zip(desired, noise)]
    
with open("input.txt", "w") as file:
    for value in output:
        file.write(f"{round(value, 1)}\n")