#!/bin/bash

set -ex

rm -rf sin_perf_pure_vec

# Use macho64 for macOS, win64 for Windows and elf64 for Linux
#nasm -f macho64 array_copy2c.asm -o array_copy2.o
as -c array_copy3a.asm -o array_copy2.o
as -c array_copy3b.asm -o array_copy2.o
as -c array_read2a.asm -o array_read.o
as -c array_read2b.asm -o array_read.o
as -c array_write2a.asm -o array_write.o
as -c array_write2b.asm -o array_write.o
as -c array_write2d.asm -o array_write.o
as -c array_write2c.asm -o array_write.o
as -c array_mul3a.asm -o array_mul.o
as -c array_fma3a.asm -o array_fma.o
#nasm -f macho64 array_read.asm
#nasm -f macho64 array_write.asm
#nasm -f macho64 kernel_sin1c.asm -o kernel_sin.o
#clang -O2 -c kernel_sin2.ll -o kernel_sin.o
clang -O3 -funroll-loops -ffast-math -c kernel_sin3.c -o kernel_sin.o
#gfortran -O3 -funroll-loops -ffast-math -c kernel_sin4.f90 -o kernel_sin.o
#clang -O1 -c array_copy2.c -o array_copy2.o

gfortran -O3 -funroll-loops -ffast-math sin_perf.f90 -o sin_perf

gfortran -O3 -funroll-loops -ffast-math sin_perf_pure.f90 -o sin_perf_pure

gfortran -O3 -funroll-loops -ffast-math -c sin_perf_pure_vec2.f90 -o sin_perf_pure_vec2.o
gfortran -O3 -funroll-loops -ffast-math -c sin_perf_pure_vec.f90 -o sin_perf_pure_vec.o
gfortran -O3 -funroll-loops -ffast-math -flto \
    -o sin_perf_pure_vec sin_perf_pure_vec.o sin_perf_pure_vec2.o \
    kernel_sin.o \
    array_copy2.o array_read.o array_write.o array_mul.o array_fma.o
