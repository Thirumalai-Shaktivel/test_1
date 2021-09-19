---
jupytext:
  formats: ipynb,md:myst
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
%pylab inline
from scipy.optimize import minimize, minimize_scalar
from scipy.special import factorial
```

```{code-cell} ipython3
x = linspace(-pi/2, pi/2, 1000)
```

```{code-cell} ipython3
def polyn(z, C):
    p = 0
    for i in range(len(C)):
        p += C[i] * z**i
    return p

def reduced_to_full(C_reduced):
    x2 = pi/2
    V2 = x2 * polyn(x2**2, concatenate(([0], C_reduced)))
    a = -(V2-1)/x2
    return concatenate(([a], C_reduced))

def P(x, par):
    return x * polyn(x**2, reduced_to_full(par))

def err(x, par):
    return max(abs(sin(x)-P(x,par)))

def Q(x, par):
    return x * polyn(x**2, par)

def errQ(x, par):
    return max(abs(sin(x)-Q(x,par)))

print(P(0, [-0.140]))
print(P(pi/2, [-0.140]))
print(P(0, [-0.140, 0.1]))
print(P(pi/2, [-0.140, 0.1]))
print(P(0, [-0.140, 0.1, 0.1]))
print(P(pi/2, [-0.140, 0.1, 0.1]))
```

```{code-cell} ipython3
res = minimize_scalar(lambda b: err(x, [b]))
C2 = [res.x]
res
```

```{code-cell} ipython3
par0 = [-1/factorial(3), +1/factorial(5)]
res = minimize(lambda par: err(x, par), par0, method='Nelder-Mead', tol=1e-15)
C3 = res.x
res
```

```{code-cell} ipython3
par0 = [-1/factorial(3), +1/factorial(5), -1/factorial(7)]
res = minimize(lambda par: err(x, par), par0, method='L-BFGS-B', tol=1e-15)
C4 = res.x
res
```

```{code-cell} ipython3
par0 = [-1/factorial(3), +1/factorial(5), -1/factorial(7), +1/factorial(9)]
res = minimize(lambda par: err(x, par), par0, method='Nelder-Mead', tol=1e-15)
C5 = res.x
res
```

```{code-cell} ipython3
par0 = [1, -1/factorial(3)]
res = minimize(lambda par: errQ(x, par), par0, method='Nelder-Mead', tol=1e-10)
Q2 = res.x
res
```

```{code-cell} ipython3
par0 = [1, -1/factorial(3), +1/factorial(5)]
res = minimize(lambda par: errQ(x, par), par0, method='Nelder-Mead', tol=1e-10)
Q3 = res.x
res
```

```{code-cell} ipython3
C1 = 4*(2-pi)/pi**3

z = x**2
Q1 = x*(1+z*C1)

P1 = x*2/pi

fn = sin(x)

plot(x, fn, label="sin(x)")
#plot(x, Q1, label="Q1")
#plot(x, P1, label="P1")
#plot(x, P2(x, b2), label="P2")
plot(x, P(x, C3), label="P3")
plot(x, P(x, C4), label="P4")
plot(x, P(x, C5), label="P5")
grid()
legend()
#ylim([0.8, 1])
#xlim([0.8, pi/2])
show()
```

```{code-cell} ipython3
e2 = err(x, C2)
e3 = err(x, C3)
e4 = err(x, C4)
e5 = err(x, C5)

plot([-pi/2, pi/2], [e2, e2], "k--")
plot([-pi/2, pi/2], [-e2, -e2], "k--")
plot(x, sin(x)-P(x, C2), label="P2")
grid()
legend()
show()

plot([-pi/2, pi/2], [e3, e3], "k--")
plot([-pi/2, pi/2], [-e3, -e3], "k--")
plot(x, sin(x)-P(x, C3), label="P3")
grid()
legend()
show()

plot([-pi/2, pi/2], [e5, e5], "k--")
plot([-pi/2, pi/2], [-e5, -e5], "k--")
plot(x, sin(x)-P(x, C5), label="P5")
grid()
legend()
show()

print(e2)
print(e3)
print(e4)
print(e5)
```

```{code-cell} ipython3
for c in reduced_to_full(C2):
    print(c)
```

```{code-cell} ipython3
for c in Q2:
    print(c)
```

```{code-cell} ipython3
def sin2(x):
    a = 0.982396485658623
    b = -0.14013802346642243
    z = x*x
    return x*(a+z*b)

def sin2b(x):
    b = 4*(2-pi)/pi**3
    z = x*x
    return x*(1+z*b)

def sin2c(x):
    a = 0.9855295359722142
    b = -0.14256672224418604
    z = x*x
    return x*(a+z*b)

def sin3(x):
    a = 0.9996476733635783
    b = -0.1655698056777521
    c = 0.0074735069135234925
    z = x*x
    return x*(a+z*(b+z*c))
```

```{code-cell} ipython3
plot(x, sin(x)-sin2(x))
plot(x, sin(x)-sin2b(x))
plot(x, sin(x)-sin2c(x))
```

```{code-cell} ipython3
plot(x, sin(x))
plot(x, sin2c(x))
```

```{code-cell} ipython3
sin2c(pi/2)
```

```{code-cell} ipython3
e2 = max(abs(sin(x)-sin2(x)))
e2b = max(abs(sin(x)-sin2b(x)))
e2c = max(abs(sin(x)-sin2c(x)))
print(e2)
print(e2b)
print(e2c)
```

```{code-cell} ipython3
from flint import ctx, arb
ctx.pretty = True
ctx.unicode = True
ctx.dps = 50

def polyn_arb(z, C):
    p = 0
    for i in range(len(C)):
        p += arb(C[i]) * arb(z)**arb(i)
    return p

def sin10q(x):
    R10 = [
        1.,
        -0.166666666666666657414808,
        0.00833333333333332974823815,
        -0.000198412698412696162806809,
        2.75573192239198747630416e-06,
        -2.50521083763502045810755e-08,
        1.60590430605664501629054e-10,
        -7.64712219118158833288484e-13,
        2.81009972710863200091251e-15,
        -7.97255955009037868891952e-18,
    ]
    x = arb(x)
    return x * polyn_arb(x*x, R10)

def err_arb(x):
    err = empty(size(x), dtype="float64")
    for i in range(size(x)):
        err[i] = float(arb(x[i]).sin() - sin10q(x[i]))
    return err
```

```{code-cell} ipython3
plot(x, err_arb(x))
```
