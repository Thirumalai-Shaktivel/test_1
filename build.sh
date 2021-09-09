#!/bin/bash

set -ex

gfortran -O3 -march=native -funroll-loops -ffast-math sin_perf.f90 -o sin_perf

gfortran -O3 -march=native -funroll-loops -ffast-math sin_perf_pure.f90 -o sin_perf_pure

gfortran -O3 -march=native -funroll-loops -ffast-math sin_perf_pure_vec.f90 -o sin_perf_pure_vec
