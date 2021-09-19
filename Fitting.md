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
```

```{code-cell} ipython3
x = linspace(-pi/2, pi/2, 1000)
```

```{code-cell} ipython3
def poly2(z, a, b):
    return a + b*z

def poly3(z, a, b, c):
    return a + b*z + c*z**2

def P2(x, b):
    a = 0
    x2 = pi/2
    C1 = x2 * poly2(x2**2, a, b) # Should be equal to 1, we subtract from `a`
    a = -(C1-1)/x2
    return x * poly2(x**2, a, b)

def P3(x, b, c):
    a = 0
    x2 = pi/2
    C1 = x2 * poly3(x2**2, a, b, c) # Should be equal to 1, we subtract from `a`
    a = -(C1-1)/x2
    return x * poly3(x**2, a, b, c)

print(P2(0, -0.140))
print(P2(pi/2, -0.140))
print(P3(0, -0.140, 0.1))
print(P3(pi/2, -0.140, 0.1))
```

```{code-cell} ipython3
def err2(x, b):
    return max(abs(sin(x)-P2(x,b)))

from scipy.optimize import minimize_scalar
res = minimize_scalar(lambda b: err2(x, b))
b2 = res.x
res
```

```{code-cell} ipython3
C1 = 4*(2-pi)/pi**3

z = x**2
Q1 = x*(1+z*C1)

P1 = x*2/pi

fn = sin(x)

plot(x, fn, label="sin(x)")
plot(x, Q1, label="Q1")
#plot(x, P1, label="P1")
plot(x, P2(x, b2), label="P2")
plot(x, P3(x, -0.140, 0.1), label="P3")
grid()
legend()
#ylim([0.8, 1])
#xlim([0.8, pi/2])
show()
```

```{code-cell} ipython3
e = err2(x, b2)

plot(x, sin(x)-Q1)
plot([-pi/2, pi/2], [e, e], "k--")
plot([-pi/2, pi/2], [-e, -e], "k--")
plot(x, sin(x)-P2(x, b2))
#plot(x, sin(x)-P3(x, -0.140, 0.1))
grid()
show()
```
