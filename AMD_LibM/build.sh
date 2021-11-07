#!/bin/bash

set -e

export AOCL_ROOT=${PWD}
export LD_LIBRARY_PATH=${PWD}/lib:$LD_LIBRARY_PATH;
make clean;
make;
./test_libm > ../sin_perf_amd_libm.txt
