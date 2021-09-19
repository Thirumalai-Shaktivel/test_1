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
par0 = [
    0.9999999999999990771,
    -0.16666666666664811048,
    8.333333333226519387e-3,
    -1.9841269813888534497e-4,
    2.7557315514280769795e-6,
    -2.5051823583393710429e-8,
    1.6046585911173017112e-10,
    -7.3572396558796051923e-13,
]
res = minimize(lambda par: errQ(x, par), par0, method='Nelder-Mead', tol=1e-15)
Q8 = res.x
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

def sin8(x):
    C8 = [
        0.9999999999999990771,
        -0.16666666666664811048,
        8.333333333226519387e-3,
        -1.9841269813888534497e-4,
        2.7557315514280769795e-6,
        -2.5051823583393710429e-8,
        1.6046585911173017112e-10,
        -7.3572396558796051923e-13,
    ]
    x = arb(x)
    return x * polyn_arb(x*x, C8)

def sin8b(x):
    Q8 = [
arb(" 0.999999999999999031480084183786065902444296849847095809072774657922366020473441"),
arb("-0.1666666666666478091660431025971523308229576066388304112246297221987315041868181"),
arb(" 0.008333333333226236038098759683296176151325159779783208234409654505577223569465132"),
arb("-0.000198412698139567192404904115804643587574232102044000573694383137466756488511536"),
arb(" 2.755731552891836710032808289793408201548040688379488262930327351721403108552863e-06"),
arb("-2.505182464813473702406655953759383864477258460718014495381867754703131132952144e-08"),
arb(" 1.604662038729048793697597237665105891528986773157667615008705486221626888484241e-10"),
arb("-7.357660119718093313121443227643942543461797330019725266916372151684021077618202e-13"),
    ]
    x = arb(x)
    return x * polyn_arb(x*x, Q8)

def sin9(x):
    Q9 = [
arb("0.9999999999999999980411193837193489944010734115794526166722417844357612393911716"),
arb("-0.1666666666666666190025821826687740525516724441879418875494884538923352031370988"),
arb("0.008333333333332993117545005979013643547619628622363944796705907018469369754777053"),
arb("-0.0001984126984115944978429391696601848090988746176470789202823782822256748946905336"),
arb("2.755731920458055704741640831557403832605412687343331745049040343416946662660435e-06"),
arb("-2.50521063810832659313337684288271976704341443702440141419879093956505098532145e-08"),
arb("1.605891864396986879261113685188936974671574173487501980351591878786167340229019e-10"),
arb("-7.642511677031907496077154260005954794987991815239827258725614915191724914857181e-13"),
arb("2.716665406378575509285749239468881129355921303392631178961930651013234454018136e-15"),
    ]
    x = arb(x)
    return x * polyn_arb(x*x, Q9)

def sin9b(x):
    Q9 = [
0.9999999999999999980411193837193489944010734115794526166722417844357612393911716,
-0.1666666666666666190025821826687740525516724441879418875494884538923352031370988,
0.008333333333332993117545005979013643547619628622363944796705907018469369754777053,
-0.0001984126984115944978429391696601848090988746176470789202823782822256748946905336,
2.755731920458055704741640831557403832605412687343331745049040343416946662660435e-06,
-2.50521063810832659313337684288271976704341443702440141419879093956505098532145e-08,
1.605891864396986879261113685188936974671574173487501980351591878786167340229019e-10,
-7.642511677031907496077154260005954794987991815239827258725614915191724914857181e-13,
2.716665406378575509285749239468881129355921303392631178961930651013234454018136e-15,
    ]
    x = arb(x)
    return x * polyn_arb(x*x, Q9)

def sin9c(x):
    Q9 = [
0.9999999999999999980411193837193489944010734115794526166722417844357612393911716,
-0.1666666666666666190025821826687740525516724441879418875494884538923352031370988,
0.008333333333332993117545005979013643547619628622363944796705907018469369754777053,
-0.0001984126984115944978429391696601848090988746176470789202823782822256748946905336,
2.755731920458055704741640831557403832605412687343331745049040343416946662660435e-06,
-2.50521063810832659313337684288271976704341443702440141419879093956505098532145e-08,
1.605891864396986879261113685188936974671574173487501980351591878786167340229019e-10,
-7.642511677031907496077154260005954794987991815239827258725614915191724914857181e-13,
2.716665406378575509285749239468881129355921303392631178961930651013234454018136e-15,
    ]
    return x * polyn(x*x, Q9)

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

def err_arb2(x):
    err = empty(size(x), dtype="float64")
    for i in range(size(x)):
        err[i] = float(arb(x[i]).sin() - sin8(x[i]))
    return err

def err_arb3(x):
    err = empty(size(x), dtype="float64")
    for i in range(size(x)):
        err[i] = float(arb(x[i]).sin() - sin8b(x[i]))
    return err

def err_arb4(x):
    err = empty(size(x), dtype="float64")
    for i in range(size(x)):
        err[i] = float(arb(x[i]).sin() - sin9(x[i]))
    return err

def err_arb5(x):
    err = empty(size(x), dtype="float64")
    for i in range(size(x)):
        err[i] = float(arb(x[i]).sin() - sin9b(x[i]))
    return err
```

```{code-cell} ipython3
plot(x, err_arb(x))
grid()
show()

plot(x, err_arb2(x))
plot(x, err_arb3(x))
grid()
show()

plot(x, err_arb4(x))
plot(x, err_arb5(x))
grid()
show()
```

```{code-cell} ipython3
plot(x, sin(x)-sin9c(x))
```
