---
jupytext:
  formats: ipynb,py:light,md:myst
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.12.0
kernelspec:
  display_name: Python 3 (ipykernel)
  language: python
  name: python3
---

```{code-cell} ipython3
!gfortran -Wall -Wextra -Wimplicit-interface -fPIC -fmax-errors=1 -g -fcheck=all -fbacktrace ../sin_accuracy.f90 -o sin_accuracy
!gfortran -Wall -Wextra -Wimplicit-interface -fPIC -fmax-errors=1 -g -fcheck=all -fbacktrace ../sin_accuracy_pure.f90 -o sin_accuracy_pure
!gfortran -Wall -Wextra -Wimplicit-interface -fPIC -fmax-errors=1 -g -fcheck=all -fbacktrace ../sin_accuracy_pure_kernel.f90 -o sin_accuracy_pure_kernel
!./sin_accuracy > sin_data.txt
!./sin_accuracy_pure > sin_pure_data.txt
!./sin_accuracy_pure_kernel > sin_pure_data_kernel.txt
```

```{code-cell} ipython3
%pylab inline
import math
from flint import ctx, arb
ctx.pretty = True
ctx.unicode = True 
ctx.dps = 50
```

```{code-cell} ipython3
def compute_sin_arb(x):
    y = empty(size(x), dtype=arb)
    for i in range(size(x)):
        y[i] = arb(x[i]).sin()
    return y
```

```{code-cell} ipython3
def diff_ulp0(x, y):
    x = float(x)
    y = float(y)
    if x == y: return 0
    return abs(x-y)/math.ulp(max(abs(x), abs(y)))
def diff_ulp1(x, y):
    x0 = x
    y0 = float(y)
    if x == y: return 0
    x = abs(float(x))
    y = abs(float(y))
    if x > y: x, y = y, x
    ulp = 0
    while x < y:
        x = nextafter(x, y)
        ulp += 1
    return ulp
diff_ulp = vectorize(diff_ulp1)
```

```{code-cell} ipython3
D = loadtxt("sin_pure_data.txt")
x = D[:,0]
sin_pos = D[:,1:4]
sin_neg = D[:,4:7]

err_pos = empty_like(sin_pos)
for i in range(3):
    err_pos[:,i] = abs(sin_pos[:,i] - compute_sin_arb(x))/abs(sin_pos[:,i])
err_neg = empty_like(sin_neg)
for i in range(3):
    err_neg[:,i] = abs(sin_neg[:,i] - compute_sin_arb(-x))/abs(sin_neg[:,i])


figure(figsize=(12, 8))
loglog(x, err_pos[:,2], "o", label="GFortran Intrinsic")
loglog(x, err_neg[:,2], "y.", label="GFortran Intrinsic (neg)")
loglog(x, err_pos[:,0], "o", label="Fast Simple")
loglog(x, err_neg[:,0], "y.", label="Fast Simple (neg)")
loglog(x, err_pos[:,1], "o", label="Fast")
loglog(x, err_neg[:,1], "y.", label="Fast (neg)")
legend()
xlabel("x")
ylabel("Relative Error of sin(x)")
#xlim([1, 1e5])
#ylim([1e-20, 1e-15])
ylim([1e-18, None])
x0 = 30
plot([x0, x0], [1e-11, 1e-5], "k--")
x1 = 1e10
plot([x1, x1], [1e-11, 1e-5], "k-")
grid()
savefig("error_rel.pdf")
show()
```

```{code-cell} ipython3
err_pos-err_neg
```

```{code-cell} ipython3
D = loadtxt("sin_data.txt")
x = D[:,0]
sin_gf = D[:,1]
D = loadtxt("sin_pure_data.txt")
#assert(max(abs(x-D[:,0])) < 1e-16)
x2 = D[:,0]
sin_pure = D[:,1]
sin_pure_double = D[:,2]

#err_gf = abs(sin_gf - compute_sin_arb(x))/abs(sin_gf)
err_gf = diff_ulp(sin_gf, compute_sin_arb(x).astype('float64'))
#err_pure = abs(sin_pure - compute_sin_arb(x2))/abs(sin_pure)
#err_pure_double = abs(sin_pure_double - compute_sin_arb(x2))/abs(sin_pure_double)
#err_pure = diff_ulp(sin_pure, compute_sin_arb(x2).astype('float64'))
err_pure_double = diff_ulp(sin_pure_double, compute_sin_arb(x2).astype('float64'))



figure(figsize=(12, 8))
semilogx(x, err_gf, ".", label="GFortran Intrinsic (%.2f ULP)" % average(err_gf))
#loglog(x2, err_pure, ".", label="Pure")
semilogx(x2, err_pure_double, ".", label="Pure double double (%.2f ULP)" % average(err_pure_double))
legend()
xlabel("x")
ylabel("ULP Error of sin(x)")
#xlim([1, 1e5])
#ylim([1e-20, 1e-15])
#ylim([1e-18, 1])
#x0 = 30
#plot([x0, x0], [1e-11, 1e-5], "k-")
grid()
savefig("error_ulp.pdf")
show()
```

```{code-cell} ipython3
D = loadtxt("sin_pure_data_kernel.txt")
x = D[:,0]
sin_pure_kernel = D[:,1]
sin_arb = compute_sin_arb(x)

err_pure_kernel = abs(sin_pure_kernel - sin_arb)
#err_pure_kernel = diff_ulp(sin_pure_kernel, sin_arb)


figure(figsize=(12, 8))
plot(x, err_pure_kernel, label="Pure kernel")
legend()
xlabel("x")
ylabel("Error of sin(x)")
#ylim([0, 1])
grid()
show()
```
