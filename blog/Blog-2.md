---
jupyter:
  jupytext:
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.13.1
  kernelspec:
    display_name: Python 3 (ipykernel)
    language: python
    name: python3
---

## Performance

In this blog post, we will obtain the theoretical and actual performance of the implementations. Let us start with the fastest version:

```fortran
subroutine sin_fastest(n, A, B)
use iso_fortran_env, only: dp=>real64
implicit none
integer, intent(in) :: n
real(dp), intent(in) :: A(n)
real(dp), intent(out) :: B(n)
real(dp), parameter :: S1 =  0.982396485658623
real(dp), parameter :: S2 = -0.14013802346642243
real(dp), parameter :: pi = 3.1415926535897932384626433832795_dp
real(dp) :: x, z, Nd
integer :: i, xi
equivalence (x,xi)
do i = 1, n
    x = A(i)
    ! Prefereed way, but currently slow:
    !     Nd = nint(x/pi)
    ! Equivalent, fast today:
    Nd = int(x/pi + 0.5_dp*sign(1._dp, x))
    x = x - Nd*pi
    ! -pi/2 < x < pi/2
    ! For even Nd, we have sin(A(i)) = sin(x)
    ! For odd Nd,  we have sin(A(i)) = sin(x+pi) = -sin(x) = sin(-x)
    ! Preferred way, but currently slow:
    !     if (modulo(int(Nd), 2) == 1) x = -x
    ! Equivalent, floating point and integer representation dependent, but fast today:
    xi = xor(shiftl(int(Nd),63), xi)
    z = x*x
    B(i) = x*(S1+z*S2)
end do
end subroutine
```

Before benchmark, Let us determine the theoretical performance peak. We count the number of operations that absolutely have to happen at the CPU, no matter how this is compiled. Looking at the body of the loop, we see one double-precision floating-point memory read (R) from `A(i)`, one memory write (W) to `B(i)`, two multiplications (`x*x` and `x*(...)`), 3 fused multiply-adds (`x/pi + 0.5_dp*sign(...)`, `x - Nd*pi` and `S1+z*S2`), one double-precision float-to-int conversion / truncation (`int(x/pi + 0.5_dp*sign(...))`) and one int-to-float conversion (`Nd = int(...)`). There was an `if (modulo(int(Nd), 2) == 1) x = -x` operation and we would like to write it as such, but unfortunately the Fortran compilers do not generate optimal code for it, which in this case on x86 architectures can be implemented using a `shift` and `xor` operations. So until compilers improve (we would like LFortran to optimize this as well), we use shift and xor directly. It seems this is the most efficient way to implement it, so we count the cost of shift and xor operations into the performance peak. Similarly, the `nint(x/pi)` operation(rounding) would be the preferred way to write the algorithm, but unfortunately compilers do not currently generate optimal code for it too, so we force it by doing an equivalent operation `int(x/pi + 0.5_dp*sign(1._dp, x))` and include the cost of one fma and one float-to-int conversion. We do not count the `0.5_dp*sign(1._dp, x)` operation into the peak as an additional multiplication and sign operation because there might be some fast way to do it with bit manipulation which does not involve multiplication and that can potentially be done at the same time as other operations by the CPU.   
Summary:

| Operation  | Count |
| ---------- | ----- |
| R          |   1   |
| W          |   1   |
| *          |   2   |
| FMA        |   3   |
| float->int |   1   |
| int->float |   1   |
| Bit Shift  |   1   |
| XOR        |   1   |

Now we look up the maximum throughputs of these operations on the 2019 MacBook Pro. It seems it is using the Intel Core [i9-9980HK](https://www.intel.com/content/www/us/en/products/sku/192990/intel-core-i99980hk-processor-16m-cache-up-to-5-00-ghz/specifications.html) processor, the microarchitecture name is [Coffee Lake](https://en.wikipedia.org/wiki/Coffee_Lake). We go to the Agner Fog's [Instruction tables](https://www.agner.org/optimize/instruction_tables.pdf), find the `Coffee Lake` section and use the "Reciprocal throughput" column which lists the number of clock cycles per instruction. This CPU can operate on 256bit `ymm` registers, each of which can contain 4 double-precision (64bit) floating-point numbers. We want the throughput per double, so we divide the "Reciprocal throughput" by 4. We obtain the following:

```{code-cell} ipython3
T = {
    "R": 0.125, # vmovaps y,m256 takes 0.5 cycles
    "W": 0.25,  # vmovaps m256,y takes 1 cycle
    "*": 0.125, # vmulpd takes 0.5 cycles
    "+": 0.125, # vaddpd takes 0.5 cycles
    "fma": 0.125, # vfmadd... family of instructions all take 0.5 cycles
    "xor": 0.0825, # takes 0.33 cycles
    "shift": 0.25, # vpsllq takes 1 cycle
    "float<->int": 0.25, # vcvtdq2pd and vcvttpd2dq each take 1 cycle
}
```

Now we use the above table with operation counts and these throughputs to obtain the theoretical performance peak. The CPU can do the following operations at the same time:

* R (total throughput 0.125 cycles per double)
* W (total throughput 0.25 cycles per double)
* Arithmetic operations (total throughput 1.4575 cycles per double, see below)

As we can see, the limiting factors are arithmetic operations in this case, so we do not include the cost of R and W into the theoretical performance peak. Finally, on older Intel architectures such as Sandy Bridge, the CPU had separate units for multiplication and addition, so it could do these two operations at maximum throughput at the same time. The Coffee Lake architecture has units that are used for all arithmetic operations, so we have to add all the throughputs together. We obtain the following theoretical peak performance in cycles per double:

```{code-cell} ipython3
fastest_peak = 2*T["*"] + 3*T["fma"] + 2*T["float<->int"] + T["shift"] + T["xor"]
fastest_peak
```
`1.4575`

Doing exactly the same analysis for the full fast `sin(x)` implementation yields:

```fortran
subroutine kernel_fast(n, A, B)
use, intrinsic :: iso_fortran_env, only: dp => real64, i8 => int64
implicit none
integer(i8), value, intent(in) :: n
real(dp), intent(in) :: A(n)
real(dp), intent(out) :: B(n)
real(dp), parameter :: p1 = 3.14159202575683594e+00_dp
real(dp), parameter :: p2 = 6.27832832833519205e-07_dp
real(dp), parameter :: p3 = 1.24467443437932268e-13_dp
real(dp) :: x, Nd
integer(i8) :: i, xi
equivalence (x,xi)
do i = 1, n
    x = A(i)
    Nd = int(x/pi + 0.5_dp*sign(1._dp, x))
    x = ((x - Nd*p1) - Nd*p2) - Nd*p3
    xi = xor(shiftl(int(Nd, i8),63), xi)
    B(i) = x
end do
do i = 1, n
    B(i) = kernel_sin(B(i))
end do
end subroutine
```

| Operation  | Count |
| ---------- | ----- |
| R          |   1   |
| W          |   1   |
| *          |   2   |
| FMA        |  11   |
| float->int |   1   |
| int->float |   1   |
| Bit Shift  |   1   |
| XOR        |   1   |

```{code-cell} ipython3
fast_peak = 2*T["*"] + 11*T["fma"] + 2*T["float<->int"] + T["shift"] + T["xor"]
fast_peak
```
`2.4575`

Now, We can benchmark the actual implementations. To do so, we first write assembly kernels for just memory reads and writes (16 times unrolled). We independently verify that this implementation is optimal and that both theoretical (0.125 and 0.25 cycles per double respectively) and actual speeds agree. We then compile these two kernels and the actual `sin(x)` implementation that we are measuring as separate compilation units and the benchmark driver is then repeatedly calling these on arrays of various sizes. For each size, it benchmarks: read, write and the `sin(x)` function. We then use the reference read/write benchmarks to compute the actual CPU frequency. For the MacBook Pro, it happens to vary between 3.5 GHz to 4.5 GHz, but it seems stable enough for the given run as seen from the graph below, the read/write reference benchmarks are right on the theoretical peak line.    
Here are the benchmark results:

![Performance](./perf_fast_intel.png)


We can see that the `fastest sin(x)` implementation runs at about 1.8 cycles per double (in L1 cache), running at about 80% peak performance:

```{code-cell} ipython3
(fastest_peak / 1.8) * 100
```

The `fast sin(x)` implementation runs at about 2.8 cycles per double, at about 87% peak:

```{code-cell} ipython3
(fast_peak / 2.8) * 100
```

```{code-cell} ipython3
2.8 / fastest_peak
```

This theoretical peak performance analysis and benchmarking is not processor or even x86 architecture dependent. The operation counts only depend on the algorithm and are the same for all CPUs. The only thing we have to know for a given CPU is:

* Maximum throughputs of all operations per array element
* Which operations the CPU can do at the same time (to know which throughputs to add together and which to ignore)

We do not include latency, since in the ideal case it can be hidden and that is true in practice also, as seen above. And we do not include operations where we are not sure what the actual cost is, such as the `0.5_dp*sign(1._dp, x)` operation above (these can be included after a thorough analysis what the most efficient way of implementing it in assembly). As such, we *know* that the theoretical performance peak is the number of clock counts that the CPU *has* to spend per array element (double in our case), no matter what. It might be that there are more operations that the CPU has to do, and so after a thorough additional analysis we can include those also. But we have to make sure we do not include any operation that the CPU does not have to do, such as latency that can be hidden with multiple techniques (out of order execution, loop unrolling, ...). As a result, the theoretical performance peak is the ideal best possible performance. One cannot get any faster than that. At the same time, we can get very close in practice as seen above.

A general rule of thumb is that if we can get within 50% of the peak, that is good enough. We actually got 87% with our fast `sin(x)` implementation. What that means is that if somebody comes with a better implementation (say in hand-optimized assembly) of the same algorithm and the same CPU, they can only get less than `2.8/fast_peak = 1.14x` faster than our current implementation. So one can decide whether it is worth spending additional time to get the possible 14% speedup or not.

The other thing we know is that if somebody figures out a faster algorithm than our "fast" implementation, they can only get it as fast as the "fastest" implementation, unless they are willing to give up the argument reduction, in which case the implementation will be unusable outside of the kernel interval of $\left(-{\pi\over2}, {\pi\over2}\right)$ (such as in the case of the Apollo AGC computer) or they want even less accuracy than 5% (such as piecewise linear approximation). So assuming you do not want to give up these two properties, you can also get `2.8 / fastest_peak = 1.92x` faster than our current "fast" implementation. In other words, you can only get less than 2x faster with a better algorithm. Most likely you would need to reduce accuracy to even have a faster algorithm, but there might be a way to keep the accuracy (more or less) and have a faster implementation, but what we do know is that it cannot even be 2x faster.

We are assuming this using double-precision numbers. If we are ok with lower accuracy, we could use single-precision numbers and those would be faster. It is also conceivable to start with a fast single (or even half) precision estimate and then iterate for higher accuracy. But it seems even such an algorithm will be at least as slow as the "fastest" one above because presumably you need at least one `fma` to refine, and the fast single or half-precision estimate will cost at least as two double-precision multiplications.

One could also think about a different way to do argument reduction. It seems one requires some kind of a "floor" operation, one way or another. But one could save the `if (modulo(int(Nd), 2) == 1) x = -x` operation by reducing to $\left(-{\pi}, {\pi}\right)$ and then fitting a polynomial over the whole period. One can adjust the above theoretical peak performance for the fastest version appropriately (remove the shift and xor operation, and add some extra fma's for a larger polynomial since we are fitting over a larger range).

All this of course assumes that we have not made a mistake in our theoretical peak performance estimate or in benchmarking. If you discover a mistake, please let us know.


### Summary:

* Our fast implementation has $10^{-15}$ relative accuracy and argument range $|x| < 4\times10^{9}$
* The given algorithm is written in pure Fortran (thus multi-platform) and running at 87% of the theoretical peak performance on the above CPU with GFortran, meaning the best possible implementation of the algorithm and the above CPU can only get 1.14x faster.
* The fastest possible implementation (of the best possible algorithm) of $\sin(x)$ on the above CPU will be less than 2x faster than our current implementation.

In this precise sense as shown by the above bullet points, we have a close to optimal "performance first, accuracy second" implementation of $\sin(x)$.


We can now compare to other implementations of `sin(x)`. Let us start with GFortran's default `sin(x)`:

![Performance](./perf_gf_intel.png)

It seems it is roughly 28x slower than our fast implementation:

```{code-cell} ipython3
80 / 2.8
```

Of course, as discussed in the previous blog post, this is the "accuracy first, performance second" implementation. So it is expected to be a lot slower than our "performance first, accuracy second" implementation, but it is more accurate.
