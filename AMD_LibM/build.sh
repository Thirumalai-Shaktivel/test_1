#!/bin/bash

set -xe

export AOCL_ROOT=${PWD}
export LD_LIBRARY_PATH=${PWD}/lib:$LD_LIBRARY_PATH;
make clean;
make;
./test_libm > ../bench_amd.txt
