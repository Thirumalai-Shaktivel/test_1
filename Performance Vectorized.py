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

# +
# Supported CPUs for analysis:
# 1 ... 2.4 GHz 8-Core Intel Core i9 (MacBook Pro 2019)
# 2 ... Apple M1 (ARM)

CPU = 1

# +
# Select one of the supported build platforms:
# 1 ... Linux Intel 64
# 2 ... macOS Intel 64
# 3 ... macOS ARM 64

# !./build.sh 2
# # !./sin_perf > sin_data.txt
# !./sin_perf_pure_vec > sin_pure_data_vec.txt
# -

# %pylab inline

# +
D = loadtxt("sin_pure_data_vec.txt")
x2 = D[:,0]
sin_pure = D[:,2]
read = D[:,3]
write = D[:,4]

GHz = 1e9
KB = 1024
MB = 1024**2

if CPU == 1:
    # Intel:
    # https://www.agner.org/optimize/instruction_tables.pdf
    # R: 0.125    (`VMOVAPS y,m256` 0.5 cycles per instruction = 4 doubles)
    # W: 0.25     (`VMOVAPS m256,y` 1 cycle per instruction = 4 doubles)
    # *: 0.125    (`vmulpd` is 0.5 cycles per 4 doubles)
    # +: 0.125
    # fma: 0.125  (`VFMADD...` is 0.5 cycles)
    #cpu_freq = 2.4 * GHz # Base
    #cpu_freq = 5.3 * GHz # Boost
    cpu_freq = 4.530 * GHz # Actual
    L1 = 64 * KB
    L2 = 256 * KB
    L3 = 16 * MB
    R_clock = 0.125
    W_clock = 0.25
    mul_clock = 0.125
    plus_clock = 0.125
    fma_clock = 0.125
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
    #
    # Note: There are two units for R, one unit for W and one unit can do both. The
    # first number in 0.25 - 0.333 - 0.5 is only writing, then read/write sharing
    # 50% of the common unit, and the last number is only the 1 unit for  W.
    # Example: For array copy, we assume the unit gets used 50%, use the middle
    # number and expect 0.333 for the peak.
    #
    #cpu_freq = 2.4 * GHz # Base
    cpu_freq = 3.2 * GHz # Boost
    L1 = 320 * KB
    L2 = 12 * MB
    L3 = None
    R_clock = 0.1667
    W_clock = 0.25
    mul_clock = 0.125
    plus_clock = 0.125
    fma_clock = 0.125
else:
    raise Exception("CPU type not supported")


# Benchmark details:
k = 8 * 2 # 8 bytes per element, 2 arrays
kernel_peak = 7*fma_clock + 2*mul_clock

def draw_peak(x, L1_peak, L1, L2, L3, n, label, color):
    L1x = L1 / (8*n)
    L2x = L2 / (8*n)
    if L3:
        L3x = L3 / (8*n)
    semilogx([x[0], L1x], [L1_peak, L1_peak], "o-", lw=1, label=label, color=color)
    semilogx([L1x, L2x], [L1_peak, L1_peak], "o-", lw=2, color=color)
    if L3:
        semilogx([L2x, L3x], [L1_peak, L1_peak], "o-", lw=3, color=color)
        semilogx([L3x, x[-1]], [L1_peak, L1_peak], "o-", lw=4, color=color)
    else:
        semilogx([L2x, x[-1]], [L1_peak, L1_peak], "o-", lw=3, color=color)



figure(figsize=(20, 12))
draw_peak(x2, kernel_peak, L1, L2, L3, 2, "Kernel Theoretical Peak Performance in L1", "g")
draw_peak(x2, R_clock, L1, L2, L3, 1, "R Theoretical Peak Performance in L1", "gray")
draw_peak(x2, W_clock, L1, L2, L3, 1, "W Theoretical Peak Performance in L1", "gray")
semilogx(x2, read * cpu_freq, ".", label="R (0.125)")
semilogx(x2, write * cpu_freq, ".", label="W (0.25)")
semilogx(x2, sin_pure * cpu_freq, "g.", label="Kernel Actual")
legend()
xlabel("Array length [double]")
ylabel("Time of sin(x) per array element")
grid()
#xlim([1e2, None])
#ylim([0, 2])
savefig("perf1.pdf")
show()

# +
i1 = 4
i2 = 9
print(read[i1:i2])
print(write[i1:i2])
Ra = average(read[i1:i2])
Rm = min(read[i1:i2])
Wa = average(write[i1:i2])
Wm = min(write[i1:i2])

print("CPU freq R avg: %.3f GHz" % (R_clock / Ra / GHz),
      "CPU freq R min: %.3f GHz" % (R_clock / Rm / GHz)
    )
print("CPU freq W avg: %.3f GHz" % (W_clock / Wa / GHz),
      "CPU freq W min: %.3f GHz" % (W_clock / Wm / GHz)
    )

print("Using CPU freq: \x1b[1m%.3f GHz\x1b[0m" % (cpu_freq / GHz))

print("R avg: %.3f" % (Ra * cpu_freq), "R min: %.3f" % (Rm * cpu_freq))
print("W avg: %.3f" % (Wa * cpu_freq), "W min: %.3f" % (Wm * cpu_freq))
kernel_min = min(sin_pure * cpu_freq)
print("kernel min: %.3f" % kernel_min)
print("kernel peak: %.3f" % kernel_peak)
print("kernel percent peak: %.2f%%" % (kernel_peak / kernel_min * 100))
