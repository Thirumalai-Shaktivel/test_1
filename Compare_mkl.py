# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py:light
#     text_representation:
#       extension: .py
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.12.0
#   kernelspec:
#     display_name: Python 3 (ipykernel)
#     language: python
#     name: python3
# ---

# !cmake mkl; cmake --build mkl;
# !mkl/sin_perf_mkl > sin_perf_mkl.txt

# %pylab inline

D = loadtxt("sin_pure_data_vec.txt")
x = D[:,0]
sin_pure = D[:,2]
D = loadtxt("sin_perf_mkl.txt")
mkl = D[:,2]
figure(figsize=(15, 10))
semilogx(x, mkl, ".")
semilogx(x, sin_pure, ".")
ylim([-0.000002, .0001])
grid()
show()
