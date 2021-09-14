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

# !./build.sh
# # !./sin_perf > sin_data.txt
# !./sin_perf_pure_vec > sin_pure_data_vec.txt

# %pylab inline

# +
#D = loadtxt("sin_data.txt")
#x = D[:,0]
#sin_gf = D[:,2]
D = loadtxt("sin_pure_data_vec.txt")
x2 = D[:,0]
sin_pure = D[:,2]
read = D[:,3]
write = D[:,4]

GHz = 1e9
KB = 1024
MB = 1024**2

# Intel:
# https://www.agner.org/optimize/instruction_tables.pdf
# R: 0.125    (`VMOVAPS y,m256` 0.5 cycles per instruction = 4 doubles)
# W: 0.25     (`VMOVAPS m256,y` 1 cycle per instruction = 4 doubles)
# *: 0.125    (`vmulpd` is 0.5 cycles per 4 doubles)
# # +: 0.125
# fma: 0.125  (`VFMADD...` is 0.5 cycles)
#cpu_freq = 2.4 * GHz # Base
#cpu_freq = 5.3 * GHz # Boost
cpu_freq = 4.590 * GHz # Actual
L1 = 64 * KB
L2 = 256 * KB
L3 = 16 * MB
k = 8 * 2  # 8 bytes per element, 2 arrays

# ARM:
# https://www.techpowerup.com/cpu-specs/core-i9-10980hk.c2276
# https://dougallj.github.io/applecpu/firestorm-simd.html
#
# Operation speeds Apple M1 (ARM64) per double
#
# R: 0.1665 - 0.2 - 0.25 (`ldr q0, [x1]` takes 0.333)
# W: 0.25 - 0.333 - 0.5   (Both `stp d0, d1, [x1]` and `str q1, [x1]` take 0.5 cycles; `stp q1, q2, [x1]` takes 1 cycle)
# *: 0.125  (`fmul.2d v0, v0, v0` takes 0.25)
# # +: 0.125  (`fadd.2d v0, v0, v0` takes 0.25)
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
#L3 = 16 * MB
k = 8 * 2 # 8 bytes per element, 2 arrays

figure(figsize=(20, 12))
#loglog(x, sin_gf, ".", label="GFortran Intrinsic")
semilogx([x2[0], x2[-1]], [0.125, 0.125], "--", color="gray")
semilogx([x2[0], x2[-1]], [0.25, 0.25], "--", color="gray")
semilogx(x2, read * cpu_freq, ".", label="R (0.125)")
semilogx(x2, write * cpu_freq, ".", label="W (0.25)")
semilogx(x2, sin_pure * cpu_freq, ".", label="Pure double double")
semilogx([L1/k, L1/k], [0, 2], "-", label="L1")
semilogx([L2/k, L2/k], [0, 2], "-", label="L2")
semilogx([L3/k, L3/k], [0, 2], "-", label="L3")
legend()
xlabel("Array length [double]")
ylabel("Time of sin(x) per array element")
grid()
#xlim([1e2, None])
ylim([0, 2])
savefig("perf1.pdf")
show()

# +
i1 = 3
i2 = 9
print(read[i1:i2])
print(write[i1:i2])
Ra = average(read[i1:i2])
Rm = min(read[i1:i2])
Wa = average(write[i1:i2])
Wm = min(write[i1:i2])

print("CPU freq R avg: %.3f GHz" % (0.125 / Ra / GHz),
      "CPU freq R min: %.3f GHz" % (0.125 / Rm / GHz)
    )
print("CPU freq W avg: %.3f GHz" % (0.25 / Wa / GHz),
      "CPU freq W min: %.3f GHz" % (0.25 / Wm / GHz)
    )

print("Using CPU freq: %.3f GHz" % (cpu_freq / GHz))

print("R avg: %.3f" % (Ra * cpu_freq), "R min: %.3f" % (Rm * cpu_freq))
print("W avg: %.3f" % (Wa * cpu_freq), "W min: %.3f" % (Wm * cpu_freq))
print("kernel min:", min(sin_pure * cpu_freq))
