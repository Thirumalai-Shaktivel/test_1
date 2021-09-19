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

def P(x, par):
    x2 = pi/2
    C1 = x2 * polyn(x2**2, [0] + par)
    a = -(C1-1)/x2
    return x * polyn(x**2, [a] + par)

def poly2(z, a, b):
    return polyn(z, [a, b])

def poly3(z, a, b, c):
    return polyn(z, [a, b, c])

def poly4(z, a, b, c, d):
    return polyn(z, [a, b, c, d])

def P2(x, b):
    return P(x, [b])

def P3(x, b, c):
    return P(x, [b, c])

def P4(x, b, c, d):
    return P(x, [b, c, d])

def err2(x, b):
    return max(abs(sin(x)-P2(x,b)))

def err3(x, b, c):
    return max(abs(sin(x)-P3(x,b,c)))

def err4(x, b, c, d):
    return max(abs(sin(x)-P4(x,b,c,d)))

print(P2(0, -0.140))
print(P2(pi/2, -0.140))
print(P3(0, -0.140, 0.1))
print(P3(pi/2, -0.140, 0.1))
print(P4(0, -0.140, 0.1, 0.1))
print(P4(pi/2, -0.140, 0.1, 0.1))
```

```{code-cell} ipython3
res = minimize_scalar(lambda b: err2(x, b))
b2 = res.x
res
```

```{code-cell} ipython3
par0 = [0.1, 0.1]
res = minimize(lambda par: err3(x, par[0], par[1]), par0, method='Nelder-Mead', tol=1e-6)
b3 = res.x[0]
c3 = res.x[1]
res
```

```{code-cell} ipython3
par0 = [-1/(2*3), +1/(2*3*4*5), -1/(2*3*4*5*6*7)]
res = minimize(lambda par: err4(x, par[0], par[1], par[2]), par0, method='L-BFGS-B', tol=1e-15)
b4 = res.x[0]
c4 = res.x[1]
d4 = res.x[2]
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
plot(x, P3(x, b3, c3), label="P3")
plot(x, P4(x, b4, c4, d4), label="P4")
grid()
legend()
#ylim([0.8, 1])
#xlim([0.8, pi/2])
show()
```

```{code-cell} ipython3
e2 = err2(x, b2)
e3 = err3(x, b3, c3)
e4 = err4(x, b4, c4, d4)

#plot(x, sin(x)-Q1)
#plot([-pi/2, pi/2], [e2, e2], "k--")
#plot([-pi/2, pi/2], [-e2, -e2], "k--")
#plot([-pi/2, pi/2], [e3, e3], "k--")
#plot([-pi/2, pi/2], [-e3, -e3], "k--")
#plot(x, sin(x)-P2(x, b2))
#plot(x, sin(x)-P3(x, b3, c3), label="P3")
plot([-pi/2, pi/2], [e4, e4], "k--")
plot([-pi/2, pi/2], [-e4, -e4], "k--")
plot(x, sin(x)-P4(x, b4, c4, d4), label="P4")
grid()
legend()
show()
print(e2)
print(e3)
print(e4)
```

```{code-cell} ipython3

```
