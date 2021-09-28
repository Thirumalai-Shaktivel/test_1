---
jupytext:
  formats: ipynb,py:light,md:myst
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

This notebook takes timings in clock cycles and visualizes the results together with their theoretical performance peaks.

```{code-cell} ipython3
%pylab inline
```

```{code-cell} ipython3
# Supported CPUs for analysis:
# 1 ... 2.4 GHz 8-Core Intel Core i9 (MacBook Pro 2019)
# 2 ... Apple M1 (ARM)

CPU = 1

GHz = 1e9
KB = 1024
MB = 1024**2

if CPU == 1:
    # Intel:
    # https://www.agner.org/optimize/instruction_tables.pdf
    # R: 0.125    (`VMOVAPS y,m256` 0.5 cycles per instruction = 4 doubles)
    # W: 0.25     (`VMOVAPS m256,y` 1 cycle per instruction = 4 doubles)
    # Arithmetics all ads up:
    # *,+,-: 0.125    (`vmulpd` is 0.5 cycles per 4 doubles)
    # fma: 0.125  (`VFMADD...` is 0.5 cycles)
    # min/max: 0.125 (`vmaxpd` is 0.5 cycles per 4 doubles)
    # int->double and double->int: 0.25  (`vcvtdq2pd` and `vcvttpd2dq` takes 1 cycle)
    # blendvpd: 0.25 (`vblendvpd` is 1 cycle)
    L1 = 64 * KB
    L2 = 256 * KB
    L3 = 16 * MB
    R_clock = 0.125
    W_clock = 0.25
    mul_clock = 0.125
    plus_clock = 0.125
    fma_clock = 0.125
    max_clock = 0.125
    abs_clock = 0.0825 # (`vandpd` takes 0.33 cycles)
    xor_clock = 0.0825
    shift_clock = 0.25 # (`vpsllq` takes 1 cycle)
    float_int_conv_clock = 0.25
    filename = "sin_perf_intel.txt"
    filename_out = "sin_perf_intel2.txt"
elif CPU == 2:
    # ARM:
    # https://www.techpowerup.com/cpu-specs/core-i9-10980hk.c2276
    # https://dougallj.github.io/applecpu/firestorm-simd.html
    #
    # Operation speeds Apple M1 (ARM64) per double
    #
    # R: 0.1665 - 0.2 - 0.25 (`ldr q0, [x1]` takes 0.333)
    # W: 0.25 - 0.333 - 0.5   (Both `stp d0, d1, [x1]` and `str q1, [x1]` take 0.5 cycles; `stp q1, q2, [x1]` takes 1 cycle)
    # *: 0.125  (`fmul.2d v0, v0, v0` takes 0.25)
    # +: 0.125  (`fadd.2d v0, v0, v0` takes 0.25)
    # fma: 0.125  (`fmla.2d v0, v0, v0` takes 0.25)
    # min/max: 0.125 (`fmaxnm.2d` takes 0.25)
    # abs: 0.125 (`fabs.2d` takes 0.25)
    # int->double, double->int: 0.125 (`fcvtzs` and `scvtf` take 0.25 each)
    #
    # Note: There are two units for R, one unit for W and one unit can do both. The
    # first number in 0.25 - 0.333 - 0.5 is only writing, then read/write sharing
    # 50% of the common unit, and the last number is only the 1 unit for  W.
    # Example: For array copy, we assume the unit gets used 50%, use the middle
    # number and expect 0.333 for the peak.
    L1 = 320 * KB
    L2 = 12 * MB
    L3 = None
    R_clock = 0.1667
    W_clock = 0.25
    mul_clock = 0.125
    plus_clock = 0.125
    fma_clock = 0.125
    max_clock = 0.125
    abs_clock = 0.125
    xor_clock = 0.125 # ?
    shift_clock = 0.125 # ?
    float_int_conv_clock = 0.125
    filename = "sin_perf_arm.txt"
    filename_out = "sin_perf_arm2.txt"
else:
    raise Exception("CPU type not supported")

D = loadtxt("sin_fastest_intel.txt")
x2 = D[0,:]
sin_fastest = D[1,:]
read = D[2,:]
write = D[3,:]

D = loadtxt("sin_perf_intel2.txt")
sin_fast = D[1,:]

D = loadtxt("gfortran_intel.txt")
sin_gf = D[1,:]


# Benchmark details:
k = 8 * 2 # 8 bytes per element, 2 arrays
#kernel_peak = (7*fma_clock + 2*mul_clock) + (3*max_clock + 3*fma_clock + 2*float_int_conv_clock + mul_clock)
fast_peak = (7*fma_clock + 2*mul_clock) + (3*fma_clock + fma_clock+2*float_int_conv_clock + xor_clock + shift_clock)
fastest_peak = (2*fma_clock + 2*mul_clock) + (fma_clock + 2*float_int_conv_clock + xor_clock + shift_clock)

def draw_peak(x, L1_peak, L1, L2, L3, n, label, color):
    L1x = L1 / (8*n)
    L2x = L2 / (8*n)
    if L3:
        L3x = L3 / (8*n)
    semilogx([x[0], L1x], [L1_peak, L1_peak], "|-", lw=1, color=color)
    semilogx([L1x, L2x], [L1_peak, L1_peak], "|-", lw=2, color=color)
    if L3:
        semilogx([L2x, L3x], [L1_peak, L1_peak], "|-", lw=3, color=color)
        semilogx([L3x, x[-1]], [L1_peak, L1_peak], "|-", lw=4, color=color)
    else:
        semilogx([L2x, x[-1]], [L1_peak, L1_peak], "|-", lw=4, color=color)



figure(figsize=(12, 8))
draw_peak(x2, fast_peak, L1, L2, L3, 2, "Fast sin(x) Theoretical Peak Performance in L1", "g")
draw_peak(x2, fastest_peak, L1, L2, L3, 2, "Fastest sin(x) Theoretical Peak Performance in L1", "r")
draw_peak(x2, R_clock, L1, L2, L3, 1, "R Theoretical Peak Performance in L1", "gray")
draw_peak(x2, W_clock, L1, L2, L3, 1, "W Theoretical Peak Performance in L1", "gray")
semilogx(x2, read, ".", label="Read (Peak %.3f)" % R_clock)
semilogx(x2, write, ".", label="Write (Peak %.3f)" % W_clock)
semilogx(x2, sin_fast, "go", label="Fast sin(x) (Peak %.3f)" % fast_peak)
semilogx(x2, sin_fastest, "ro", label="Fastest sin(x) (Peak %.3f)" % fastest_peak)
legend()
xlabel("Array length [double]")
ylabel("Clock cycles per array element")
grid()
#xlim([1e2, None])
ylim([0, 4])
title("Performance of sin(x) implementations")
savefig("perf_fast_intel.png")
show()
```

```{code-cell} ipython3
figure(figsize=(12, 8))
draw_peak(x2, fast_peak, L1, L2, L3, 2, "Fast sin(x) Theoretical Peak Performance in L1", "g")
draw_peak(x2, fastest_peak, L1, L2, L3, 2, "Fastest sin(x) Theoretical Peak Performance in L1", "r")
draw_peak(x2, R_clock, L1, L2, L3, 1, "R Theoretical Peak Performance in L1", "gray")
draw_peak(x2, W_clock, L1, L2, L3, 1, "W Theoretical Peak Performance in L1", "gray")
semilogx(x2, read, ".", label="Read (Peak %.3f)" % R_clock)
semilogx(x2, write, ".", label="Write (Peak %.3f)" % W_clock)
semilogx(x2, sin_fast, "go", label="Fast sin(x) (Peak %.3f)" % fast_peak)
semilogx(x2, sin_fastest, "ro", label="Fastest sin(x) (Peak %.3f)" % fastest_peak)
semilogx(x2, sin_gf, "yo", label="GFortran sin(x)")
legend()
xlabel("Array length [double]")
ylabel("Clock cycles per array element")
grid()
#xlim([1e2, None])
#ylim([0, 4])
title("Performance of sin(x) implementations")
savefig("perf_gf_intel.png")
show()
```
