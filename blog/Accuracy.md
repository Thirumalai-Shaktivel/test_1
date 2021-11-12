---
jupytext:
  formats: ipynb,py:light,md:myst
  text_representation:
    extension: .md
    format_name: myst
    format_version: 0.13
    jupytext_version: 1.13.1
kernelspec:
  display_name: Python 3 (ipykernel)
  language: python
  name: python3
---

```{code-cell} ipython3
%pylab inline
import math
from flint import ctx, arb
ctx.pretty = True
ctx.unicode = True 
ctx.dps = 50
```

```{code-cell} ipython3
D = loadtxt("accuracy_all.txt")
x = D[:,0]
sin_pos = D[:,1:5]
sin_neg = D[:,5:9]
sin_fastest2 = D[:,9]

@vectorize
def arb_sin(x): return arb(x).sin()

err_pos = empty_like(sin_pos)
for i in range(4):
    err_pos[:,i] = abs(sin_pos[:,i] - arb_sin(x))/abs(sin_pos[:,i])
err_neg = empty_like(sin_neg)
for i in range(4):
    err_neg[:,i] = abs(sin_neg[:,i] - arb_sin(-x))/abs(sin_neg[:,i])
    
# Given that sin(x) = -sin(-x) numerically:
assert abs(sin_pos-(-sin_neg)).max() == 0.0
# we do not plot the error of sin(-x) below, since it overlaps with sin(x)

err_fastest2 = abs(sin_fastest2 - arb_sin(x))

figure(figsize=(12, 8))
loglog(x, err_pos[:,3], "o", label="GFortran Intrinsic")
#loglog(x, err_neg[:,3], "y.", label="GFortran Intrinsic (neg)")
loglog(x, err_pos[:,0], "o", label="Fast Simple Reduction")
#loglog(x, err_neg[:,0], "y.", label="Fast Simple (neg)")
loglog(x, err_pos[:,1], "o", label="Fast")
#loglog(x, err_neg[:,1], "y.", label="Fast (neg)")
loglog(x, err_pos[:,2], "o", label="Fastest")
#loglog(x, err_neg[:,2], "y.", label="Fastest (neg)")
loglog(x, err_fastest2[:], "o", label="Fastest2")
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
savefig("error_rel.png")
show()
```

We only plotted the error of $\sin(x)$ for $x>0$, because the values of $\sin(-x)$ are exactly equal to $-\sin(x)$ numerically, so the plots would overlap:

```{code-cell} ipython3
abs(sin_pos+sin_neg).max()
```

```{code-cell} ipython3
D = loadtxt("accuracy_all.txt")
#assert(max(abs(x-D[:,0])) < 1e-16)
x2 = D[:,0]
sin_pure = D[:,1]
sin_pure_double = D[:,2]
x = x2
sin_gf = D[:, 4]


@vectorize
def diff_ulp(x, y):
    x = float(x)
    y = float(y)
    if x == y: return 0
    return abs(x-y)/math.ulp(max(abs(x), abs(y)))

#err_gf = abs(sin_gf - compute_sin_arb(x))/abs(sin_gf)
err_gf = diff_ulp(sin_gf, arb_sin(x).astype('float64'))
#err_pure = abs(sin_pure - compute_sin_arb(x2))/abs(sin_pure)
#err_pure_double = abs(sin_pure_double - compute_sin_arb(x2))/abs(sin_pure_double)
#err_pure = diff_ulp(sin_pure, compute_sin_arb(x2).astype('float64'))
err_pure_double = diff_ulp(sin_pure_double, arb_sin(x2).astype('float64'))



figure(figsize=(12, 8))
semilogx(x, err_gf, ".", label="GFortran Intrinsic (%.2f ULP)" % average(err_gf))
#loglog(x2, err_pure, ".", label="Pure")
semilogx(x2, err_pure_double, ".", label="Fast sin(x) (%.2f ULP)" % average(err_pure_double))
legend()
xlabel("x")
ylabel("ULP Error of sin(x)")
#xlim([1, 1e5])
#ylim([1e-20, 1e-15])
#ylim([1e-18, 1])
#x0 = 30
#plot([x0, x0], [1e-11, 1e-5], "k-")
grid()
savefig("error_ulp.png")
show()
```
