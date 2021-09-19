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
C1 = 4*(2-pi)/pi**3

z = x**2
Q1 = x*(1+z*C1)

P1 = x*2/pi
P2 = lambda b: x * ((2/pi - b*(pi/2)**2) + x**2*b)

fn = sin(x)

plot(x, fn, label="sin(x)")
plot(x, Q1, label="Q1")
#plot(x, P1, label="P1")
plot(x, P2(-0.140), label="P2")
grid()
legend()
#ylim([0.8, 1])
#xlim([0.8, pi/2])
show()
```

```{code-cell} ipython3
err = sin(x)-Q1

plot(x, sin(x)-Q1)
plot(x, sin(x)-P2(-0.140))
grid()
show()
```
