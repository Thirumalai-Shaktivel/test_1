---
jupyter:
  jupytext:
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.12.0
  kernelspec:
    display_name: Python 3 (ipykernel)
    language: python
    name: python3
---

# Designing Math Intrinsics for LFortran

Every Fortran (including C and C++) compiler has a runtime library that implements math functions such as $\sin(x)$, $\cos(x)$, $\tan(x)$, $\exp(x)$, $\mathrm{erf}(x)$, etc. In this series of blog posts, we will investigate how to design and implement or reuse such functions to be used in any Fortran compiler, such as LFortran. We will explore from first principles how to go about designing such functions, and then we will implement the fastest possible version, benchmark it and prove that the performance is optimal using a theoretical peak performance analysis.


## Design

The domain of Fortran is high-performance numerical computing. A typical workflow is to compile in Debug mode, when the compiler instruments the code with runtime checks (such as array bounds checks) but does not do any optimizations and run the production code on production data to see whether any errors occur. If everything works then the code is recompiled in Release mode when all optimizations are turned on. One must then run the same problem and see if any answers have significantly changed. If everything looks good, one can then run a physical problem.

In Debug mode, it is a good idea to deliver full accuracy for intrinsic functions like $\sin(x)$, to reduce any potential source of errors. In Release mode, on the other hand, we typically want the absolute best performance (while still getting the correct answers).

For this reason, we have to ship with at least two sets of functions:

1. Accuracy first, performance second
2. Performance first, accuracy second

The accuracy first version is the one to be used in Debug mode. The goal is to get as accurate answers as possible for every single or double-precision number (no matter how large), and while keeping the accuracy, get the best performance possible. Examples of math functions that target accuracy first are the default `sin` function in GFortran, GCC, Clang, the `libm` library in `libc`, the `openlibm` library and many others. These functions are very accurate, typically they return the exactly rounded answer to the last bit (0 ULP) or the next floating-point number (1 ULP). There are even attempts to improve the accuracy further and implement functions that always return the exactly rounded answer. This amazing accuracy does not come for free. However, the implementations typically have to work very hard to get it, meanwhile sacrificing performance.

The goal of the performance first version is to obtain the best possible performance. While keeping the good performance as much as possible, and getting it as accurate as one can. Typically these functions have a reduced range of the argument for which the functions return valid answer (such as $|x| < 10^{10}$) and the accuracy of the answer is lower than the accuracy first version, such as "only" $10^{-15}$ relative accuracy. We wrote "only" because it is actually very high accuracy, but the error can be larger than 1 ULP. Together with the reduced range of an allowed argument that means such a fast function can potentially break some codes.

An idea of a good possible workflow is for the compiler to insert argument checks in Debug mode, and if the code passes, then one can switch to the fast functions. One still has to verify that the final accuracy is good enough for the given problem. If a given problem does not work with the fast functions, then one does not need to use them, one can always use the accuracy first versions. For many problems however the fast versions work great and deliver the best possible performance.

<!-- #region -->
## Accuracy

In this post we will measure accuracy of various implementations. We will compare:

* the default `sin(x)` in GFortran 9.3.0 on MacBook Pro 2019 (Intel based)
* Fast `sin(x)` in pure Fortran
* Fast `sin(x)` with a simple reduction algorithm
* Fastest possible very low accuracy `sin(x)`

We will discuss and benchmark the fast `sin(x)` versions in the next blog post. Here we will measure their accuracy.

Relative error of various `sin(x)` implementations:

![Relative Error](./error_rel.png)

As you can see, the simple reduction version does not have good enough accuracy. That is caused by the fact that in `y = y - nint(y/pi)*pi` we are subtracting two very close numbers and get catastrophic cancellation.

This issue is fixed by splitting `pi` into a sum of several numbers, each having a certain number of bits zeroed. By subtracting part by part, one obtains the exact answer up to what fits into a 32-bit integer, about $x = 4\times10^{9}$.

The fastest version has about 5% accuracy ($5\times10^{-2}$).

We can also compare errors in terms of [ULP](https://en.wikipedia.org/wiki/Unit_in_the_last_place) (Unit in the last place). Such an error can be computed using:
```python
@vectorize
def ulp_error(x:float, y:float):
    if x == y:
        return 0
    else:
        return abs(x-y)/math.ulp(max(abs(x), abs(y)))
```
We will only compare the fast version and the GFortran version:

![ULP Error](./error_ulp.png)

As can be seen, the GFortran's version is extremely accurate, over 80% of the time it is exactly rounded. And in the rest of the time, it is the next floating-point number (1 ULP) to the exactly rounded answer.

The fast `sin(x)` version is still very accurate, up to 5 ULP with an average of 1.16 ULP. But it is not as accurate as GFortran's version.
<!-- #endregion -->
