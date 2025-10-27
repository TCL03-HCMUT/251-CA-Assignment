import argparse
import numpy as np
import os

def read_signal(path):
    with open(path, "r") as f:
        return np.array([float(line.strip()) for line in f if line.strip() != ""])

def estimate_ac(x, maxlag, biased=True):
    N = len(x)
    ac_full = np.correlate(x, x, mode='full')  # lags -(N-1)...(N-1)
    center = N - 1
    ac = ac_full[center:center + maxlag + 1].astype(float)
    if biased:
        ac /= N
    else:
        ac = np.array([ac_full[center + k] / (N - k) for k in range(maxlag + 1)], dtype=float)
    return ac

def estimate_xd(x, d, maxlag, biased=True):
    N = len(x)
    cc_full = np.correlate(d, x, mode='full')  # cross-correlation d vs x, lags -(N-1)...(N-1)
    center = N - 1
    cc = cc_full[center:center + maxlag + 1].astype(float)
    if biased:
        cc /= N
    else:
        cc = np.array([cc_full[center + k] / (N - k) for k in range(maxlag + 1)], dtype=float)
    return cc

def toeplitz_from_ac(ac, M):
    # ac is autocorr for lags 0..M-1
    return np.array([[ac[abs(i - j)] for j in range(M)] for i in range(M)], dtype=float)

def wiener_hopf(x, d, M, reg=1e-8, biased=True):
    ac = estimate_ac(x, M - 1, biased=biased)  # need lags 0..M-1
    R = toeplitz_from_ac(ac, M)
    p = estimate_xd(x, d, M - 1, biased=biased)[:M]
    # regularize if R is near-singular
    R_reg = R + reg * np.eye(M)
    w = np.linalg.solve(R_reg, p)
    return w, R, p

def apply_fir(x, w):
    N = len(x)
    M = len(w)
    y = np.zeros(N)
    for n in range(N):
        kmax = min(n, M - 1)
        y[n] = np.dot(w[:kmax+1], x[n-kmax:n+1][::-1])
    return y

def main():
    parser = argparse.ArgumentParser(description="Wiener–Hopf Wiener filter from input and desired files")
    parser.add_argument("--input", default="input.txt")
    parser.add_argument("--desired", default="desired.txt")
    parser.add_argument("--order", type=int, default=10, help="Filter order (number of taps)")
    parser.add_argument("--biased", action="store_true", help="Use biased autocorrelation (divide by N). Default is unbiased")
    args = parser.parse_args()

    x = read_signal(args.input)
    d = read_signal(args.desired)
    if len(x) != len(d):
        raise ValueError("input and desired must have same length")

    M = args.order
    # compute Wiener solution
    w, R, p = wiener_hopf(x, d, M, reg=1e-8, biased=args.biased)
    y = apply_fir(x, w)
    mse = np.mean((d - y) ** 2)

    # save results
    np.savetxt("wiener_coeffs.txt", w, fmt="%.6f")
    np.savetxt("wiener_output.txt", y, fmt="%.6f")
    print(f"Wiener filter order={M}, MSE={mse:.6f}")
    print("Coefficients saved to wiener_coeffs.txt, output saved to wiener_output.txt")

if __name__ == "__main__":
    main()

