#!/bin/bash

set -ex

gfortran -O3 -march=native -funroll-loops -c b.f90 -o b.o
gfortran -O3 -march=native -funroll-loops -ffast-math -c sin_perf_pure.f90 -o sin_perf_pure.o
gfortran -flto -o a.out sin_perf_pure.o b.o
