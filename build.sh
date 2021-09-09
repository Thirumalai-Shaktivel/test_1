#!/bin/bash

set -ex

gfortran -O3 -march=native -funroll-loops -ffast-math sin_perf.f90 -o sin_perf

gfortran -O3 -march=native -funroll-loops -ffast-math sin_perf_pure.f90 -o sin_perf_pure

gfortran -O3 -march=native -funroll-loops -ffast-math -c sin_perf_pure_vec2.f90 -o sin_perf_pure_vec2.o
gfortran -O3 -march=native -funroll-loops -ffast-math -c sin_perf_pure_vec.f90 -o sin_perf_pure_vec.o
gfortran -O3 -march=native -funroll-loops -ffast-math -flto -o sin_perf_pure_vec sin_perf_pure_vec.o sin_perf_pure_vec2.o
