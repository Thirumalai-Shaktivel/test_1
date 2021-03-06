# Compile and run benchmarks

This should work on all platforms. In `./build.sh 3` choose a number based on
your platform:
```
1 ... Linux Intel 64
2 ... macOS Intel 64
3 ... macOS ARM 64
```
Then:
```
conda create -n mi gfortran jupyter matplotlib jupytext
conda activate mi
./build.sh 3
./benchmark 1 > bench_fast.txt
./benchmark 2 > bench_fastest.txt
./benchmark 3 > bench_gfortran.txt
./benchmark 4 > bench_fastest2.txt
jupyter notebook Postprocess.md
```

The notebook saves the postprocessed results to a file such as
`gfortran_intel.txt`. You can then copy it to a file such as
`blog/sin_perf_arm2.txt` that you can then use in the notebook to do the final
plots:
```
cd blog
jupyter notebook Performance.md
```

# Compile and run accuracy

```
conda create -n mi gfortran jupyter matplotlib jupytext python-flint
conda activate mi
./build.sh 3
./accuracy > blog/accuracy_all.txt
cd blog
jupyter notebook Accuracy.md
```

Note: on M1 the python-flint package does not exist yet. Workaround for now:
```
conda install libflint cython arb
pip install python-flint
```

# Compile with MKL

mamba create -n mkl mkl-devel

#### Alternative Download

oneMKL is included in the Intel® oneAPI Base Toolkit. Download online installer
to select the required package(oneMKL(813MB)) through the following link:
[Intel® oneAPI Base Toolkit](https://www.intel.com/content/www/us/en/developer/tools/oneapi/base-toolkit-download.html?operatingsystem=linux&distributions=webdownload&options=online)
