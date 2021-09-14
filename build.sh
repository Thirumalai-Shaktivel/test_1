#!/bin/bash

set -ex

# Use macho64 for macOS, win64 for Windows and elf64 for Linux
nasm -f macho64 array_copy2c.asm -o array_copy2.o
nasm -f macho64 array_read.asm
nasm -f macho64 array_write.asm
#nasm -f macho64 kernel_sin1c.asm -o kernel_sin.o
#clang -O2 -march=native -c kernel_sin2.ll -o kernel_sin.o
#clang -O3 -march=native -funroll-loops -ffast-math -c kernel_sin3.c -o kernel_sin.o
gfortran -O3 -march=skylake -funroll-loops -ffast-math -c kernel_sin4.f90 -o kernel_sin.o
#clang -c array_copy2.c -o array_copy2.o

gfortran -O3 -march=skylake -funroll-loops -ffast-math sin_perf.f90 -o sin_perf

gfortran -O3 -march=skylake -funroll-loops -ffast-math sin_perf_pure.f90 -o sin_perf_pure

gfortran -O3 -march=skylake -funroll-loops -ffast-math -c sin_perf_pure_vec2.f90 -o sin_perf_pure_vec2.o
gfortran -O3 -march=skylake -funroll-loops -ffast-math -c sin_perf_pure_vec.f90 -o sin_perf_pure_vec.o
gfortran -O3 -march=skylake -funroll-loops -ffast-math -flto \
    -o sin_perf_pure_vec sin_perf_pure_vec.o sin_perf_pure_vec2.o \
    array_copy2.o array_read.o array_write.o kernel_sin.o
