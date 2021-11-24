#!/bin/bash

set -e


if [[ $1 != "" ]]; then
    platform=$1
else
    echo "Must specify platform."
    echo "./build.sh NUM"
    echo
    echo "Supported platforms:"
    echo "1 ... Linux Intel 64"
    echo "2 ... macOS Intel 64"
    echo "3 ... macOS ARM 64"
    exit 1
fi

set -x
rm -rf sin_perf_pure_vec


if [[ $platform == "3" ]]; then
    #as -c array_copy3a.asm -o array_copy2.o
    #as -c array_copy3b.asm -o array_copy2.o
    #as -c array_read2a.asm -o array_read.o
    as -c array_read2b.asm -o array_read.o
    #as -c array_write2a.asm -o array_write.o
    #as -c array_write2b.asm -o array_write.o
    #as -c array_write2d.asm -o array_write.o
    as -c array_write2c.asm -o array_write.o
    #as -c array_mul3a.asm -o array_mul.o
    #as -c array_fma3a.asm -o array_fma.o
    #as -c kernel_sin5a.asm -o kernel_sin.o
    #as -c kernel_sin5b.asm -o kernel_sin.o
elif [[ $platform == "2" || $platform == "1" ]]; then
    # Use macho64 for macOS, win64 for Windows and elf64 for Linux
    if [[ $platform == "1" ]]; then
        nasm_f="elf64"
        nasm -f $nasm_f array_read1.asm
        nasm -f $nasm_f array_write1.asm
    else
        nasm_f="macho64"
        nasm -f $nasm_f array_read.asm
        nasm -f $nasm_f array_write.asm
    fi
    #clang -c array_copy2.c -o array_copy2.o
    # nasm -f $nasm_f array_copy2c.asm -o array_copy2.o
    # nasm -f $nasm_f array_read.asm
    # nasm -f $nasm_f array_write.asm
    # nasm -f $nasm_f kernel_sin1c.asm -o kernel_sin.o
    # nasm -f $nasm_f array_mul4a.asm -o array_mul.o
    # nasm -f $nasm_f array_fma4a.asm -o array_fma.o
    # clang -O2 -c kernel_sin2.ll -o kernel_sin.o
    # clang -O3 -funroll-loops -ffast-math -c kernel_sin3.c -o kernel_sin.o
    #clang -O1 -c array_copy2.c -o array_copy2.o
    # nasm -f $nasm_f kernel_sin1a.asm -o kernel_sin.o
    #clang -O2 -march=native -c kernel_sin2.ll -o kernel_sin.o
    #clang -O3 -march=native -funroll-loops -ffast-math -c kernel_sin3.c -o kernel_sin.o
fi

# gfortran -O3 -funroll-loops -ffast-math sin_perf.f90 -o sin_perf

# gfortran -O3 -funroll-loops -ffast-math sin_perf_pure.f90 -o sin_perf_pure

# gfortran -O3 -funroll-loops -ffast-math -c sin_perf_pure_vec2.f90 -o sin_perf_pure_vec2.o
# gfortran -O3 -funroll-loops -ffast-math -c sin_perf_pure_vec.f90 -o sin_perf_pure_vec.o
# gfortran -O3 -funroll-loops -ffast-math -flto \
#     -o sin_perf_pure_vec sin_perf_pure_vec.o sin_perf_pure_vec2.o \
#     kernel_sin.o \
#     array_copy2.o array_read.o array_write.o array_mul.o array_fma.o

FFLAGS="-O3 -march=native -funroll-loops -ffast-math"

gfortran $FFLAGS -c sin_implementations.f90 -o sin_implementations.o
gfortran $FFLAGS -c benchmark.f90 -o benchmark.o
gfortran $FFLAGS -c accuracy.f90 -o accuracy.o
gfortran $FFLAGS -flto \
    -o benchmark benchmark.o sin_implementations.o \
    array_read.o array_write.o
gfortran $FFLAGS -flto \
    -o accuracy accuracy.o sin_implementations.o

if [[ $platform == "1" ]]; then
    # Benchmarks
    ## MKL
    cmake mkl; cmake --build mkl
    mkl/sin_perf_mkl > bench_mkl.txt

    ## AMD_LibM
    cd AMD_LibM
    export AOCL_ROOT=${PWD}
    export LD_LIBRARY_PATH=${PWD}/lib:$LD_LIBRARY_PATH;
    make clean;
    make;
    ./test_libm > ../bench_amd.txt
    cd ..

    ## VDT (VectoriseD maTh)
    g++ "VDT (VectoriseD maTh)"/main.c -o bench_vdt
    ./bench_vdt > bench_vdt.txt
fi
