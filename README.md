# Compile on Apple M1

```
conda create -n mi gfortran jupyter matplotlib jupytext
conda activate mi
./build.sh 3
./sin_performance > sin_pure_data_vec.txt
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

# Compile with MKL

mamba create -n mkl mkl-devel

#### Alternative Download

oneMKL is included in the Intel® oneAPI Base Toolkit. Download online installer
to select the required package(oneMKL(813MB)) through the following link:
[Intel® oneAPI Base Toolkit](https://www.intel.com/content/www/us/en/developer/tools/oneapi/base-toolkit-download.html?operatingsystem=linux&distributions=webdownload&options=online)
