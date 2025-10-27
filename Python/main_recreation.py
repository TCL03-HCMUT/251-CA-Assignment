import numpy as np
import argparse

def read_signal(path):
    with open(path, "r") as f:
        return np.array([float(line.strip()) for line in f if line.strip() != ""])
    

def autocorr(x, maxlag):
    N = len(x)
    r = []
    for k in range(maxlag + 1):
        s = 0.0
        for n in range(k, N):
            s += x[n] * x[n - k]
        r.append(s / N)  # biased (divide by N)
    return r

def crosscorr(x, d, maxlag):
    N = len(x)
    p = []
    for k in range(maxlag + 1):
        s = 0.0
        for n in range(k, N):
            s += d[n] * x[n - k]
        p.append(s / N)
    return p

def toeplitz(r, M):
    return [[r[abs(i - j)] for j in range(M)] for i in range(M)]
    

def main():
    parser = argparse.ArgumentParser(description="Wiener–Hopf Wiener filter from input and desired files")
    parser.add_argument("--input", default="input.txt")
    parser.add_argument("--desired", default="desired.txt")
    parser.add_argument("--order", type=int, default=10, help="Filter order (number of taps)")
    args = parser.parse_args()
    
    x = read_signal(args.input)
    d = read_signal(args.desired)
    if len(x) != len(d):
        raise ValueError("input and desired must have same length")

    M = args.order
    r = autocorr(x, M - 1)
    p = crosscorr(x, d, M - 1)
    R = toeplitz(r, M)