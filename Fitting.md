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
res = minimize(lambda par: err(x, par), par0, method='Nelder-Mead', tol=1e-6)
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

```
