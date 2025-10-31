#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#define EPSILON 1e-9

void solve_linear(float **a, float* b, float* solution, int n) {
    float *A = malloc(n * n * sizeof(float));
   
    float *b_copy = malloc(n * sizeof(float));
    for (int i = 0; i < n; i++) {
        b_copy[i] = b[i];
        for (int j = 0; j < n; j++) {
            A[i * n + j] = a[i][j];
        }
    }


   for (int k = 0; k < n; k++) {
        // --- Pivot selection ---
        int piv = k;
        float maxv = fabs(A[k * n + k]);
        for (int i = k + 1; i < n; i++) {
            if (fabs(A[i * n + k]) > maxv) {
                maxv = fabs(A[i * n + k]);
                piv = i;
            }
        }
        if (maxv < EPSILON) A[k * n + k] += EPSILON;

        // --- Swap rows if needed ---
        if (piv != k) {
            for (int j = 0; j < n; j++) {
                float tmp = A[k * n + j];
                A[k * n + j] = A[piv * n + j];
                A[piv * n + j] = tmp;
            }
           
            float tb = b_copy[k];
            b_copy[k] = b_copy[piv];
            b_copy[piv] = tb;
        }

        // --- Elimination ---
        for (int i = k + 1; i < n; i++) {
            float factor = (fabs(A[k*n + k]) < EPSILON) ? 0.0 : (A[i*n + k] / A[k*n + k]);
            b_copy[i] -= factor * b_copy[k];
            for (int j = k; j < n; j++) {
                A[i*n + j] -= factor * A[k*n + j];
            }
        }
    }

    // --- Back substitution ---
    for (int i = n - 1; i >= 0; i--) {
        float s = b_copy[i];
        for (int j = i + 1; j < n; j++) {
            s -= A[i*n + j] * solution[j];
        }
        solution[i] = s / ((fabs(A[i*n + i]) < EPSILON) ? (A[i*n + i] + EPSILON) : A[i*n + i]);
    }

    free(b_copy);
    free(A);
    }
   
