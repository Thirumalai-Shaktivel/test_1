# Compile on Apple M1

```
conda create -n mi gfortran jupyter matplotlib
conda activate mi
./build.sh 3
./sin_performance
```

# Compile with MKL

mamba create -n mkl mkl-devel

#### Alternative Download

oneMKL is included in the Intel® oneAPI Base Toolkit. Download online installer
to select the required package(oneMKL(813MB)) through the following link:
[Intel® oneAPI Base Toolkit](https://www.intel.com/content/www/us/en/developer/tools/oneapi/base-toolkit-download.html?operatingsystem=linux&distributions=webdownload&options=online)
