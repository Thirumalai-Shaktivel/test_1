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

# !gfortran -Wall -Wextra -Wimplicit-interface -fPIC -fmax-errors=1 -g -fcheck=all -fbacktrace sin_accuracy.f90 -o sin_accuracy
# !gfortran -Wall -Wextra -Wimplicit-interface -fPIC -fmax-errors=1 -g -fcheck=all -fbacktrace sin_accuracy_pure.f90 -o sin_accuracy_pure
# !gfortran -Wall -Wextra -Wimplicit-interface -fPIC -fmax-errors=1 -g -fcheck=all -fbacktrace sin_accuracy_pure_kernel.f90 -o sin_accuracy_pure_kernel
# !./sin_accuracy > sin_data.txt
# !./sin_accuracy_pure > sin_pure_data.txt
# !./sin_accuracy_pure_kernel > sin_pure_data_kernel.txt

# %pylab inline
import math
from flint import ctx, arb
ctx.pretty = True
ctx.unicode = True 
ctx.dps = 50


# +
def renormalize(xh, xl):
    zh = xh+xl
    zl = xh-zh+xl
    return (zh, zl)

def split(xh, xl):
    c = 2**27+1. # = 134217729.
    up = xh*c
    zh = (xh-up)+up
    zl = xh-zh
    return (zh, zl)

# xh > yh
def dd_add(xh, xl, yh, yl):
    zh = xh+yh
    sl = xh-zh+yh+yl+xl
    return renormalize(zh, sl)

# dd_add(xh, 0, yh, yl)[0]
def dd_add1(xh, yh, yl):
    zh = xh+yh
    zl = xh-zh+yh+yl
    return zh+zl

def dd_mul(xh, xl, yh, yl):
    zh = xh*yh;
    u1, u2 = split(xh, xl)
    v1, v2 = split(yh, yl)
    zl = (((u1*v1-zh)+(u1*v2))+(u2*v1))+(u2*v2)
    zl += xh*yl + xl*yh
    return renormalize(zh, zl)

def mymod2(xh):
    if (abs(xh) < 1e16):
        yh = 6.283185307179586
        yl = 2.4492935982947064e-16
        N = math.floor(xh/yh)
        zh, zl = dd_mul(-N, 0, yh, yl)
        #zh, zl = dd_add(xh, 0, zh, zl)
        zh = dd_add1(xh, zh, zl)
        return zh
    else:
        y2 = 2*arb.pi()
        z = xh - (xh/y2).floor()*y2
        return z


# -

def compute_sin_arb(x):
    y = empty(size(x), dtype=arb)
    for i in range(size(x)):
        y[i] = arb(x[i]).sin()
    return y


# +
def floor(x):
    return int(x)

def mymod(x):
    y = empty(size(x), dtype="double")
    y2 = 2*pi
    for i in range(size(x)):
        #y[i] = x[i] - floor(x[i]/y2)*y2
        y[i] = mymod2(float(x[i]))
    return y

def arbmod(x):
    y = empty(size(x), dtype=arb)
    y2 = 2*arb.pi()
    for i in range(size(x)):
        y[i] = x[i] - (x[i]/y2).floor()*y2
    return y


# -

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
    #if ulp > 30:
    #    print(x0)
    #    print(y0)
    #    print(abs(x0-y0)/y, ulp)
    return ulp
diff_ulp = vectorize(diff_ulp1)

# +
D = loadtxt("sin_data.txt")
x = D[:,0]
sin_gf = D[:,1]
D = loadtxt("sin_pure_data.txt")
#assert(max(abs(x-D[:,0])) < 1e-16)
x2 = D[:,0]
sin_pure = D[:,1]
sin_pure_double = D[:,2]

err_gf = abs(sin_gf - compute_sin_arb(x))/abs(sin_gf)
#err_gf = diff_ulp(sin_gf, compute_sin_arb(x))
err_pure = abs(sin_pure - compute_sin_arb(x2))/abs(sin_pure)
err_pure_double = abs(sin_pure_double - compute_sin_arb(x2))/abs(sin_pure_double)
#err_pure = diff_ulp(sin_pure, compute_sin_arb(x2))


mod_pure = mymod(x)
mod_arb = arbmod(x)
err_mod = abs(mod_pure-mod_arb)


figure(figsize=(12, 8))
loglog(x, err_gf, ".", label="GFortran Intrinsic")
loglog(x2, err_pure, ".", label="Pure")
loglog(x2, err_pure_double, ".", label="Pure double double")
#loglog(x, err_mod, "r-", label="Modulo")
legend()
xlabel("x")
ylabel("Relative Error of sin(x)")
#xlim([1, 1e5])
#ylim([1e-20, 1e-15])
ylim([1e-18, 1])
x0 = 30
plot([x0, x0], [1e-11, 1e-5], "k--")
x1 = 5000
plot([x1, x1], [1e-11, 1e-5], "k-")
grid()
savefig("error_rel.pdf")
show()

# +
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



mod_pure = mymod(x)
mod_arb = arbmod(x)
err_mod = abs(mod_pure-mod_arb)


figure(figsize=(12, 8))
semilogx(x, err_gf, ".", label="GFortran Intrinsic (%.2f ULP)" % average(err_gf))
#loglog(x2, err_pure, ".", label="Pure")
semilogx(x2, err_pure_double, ".", label="Pure double double (%.2f ULP)" % average(err_pure_double))
#loglog(x, err_mod, "r-", label="Modulo")
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

# +
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
#ylim([0, 3])
grid()
show()
