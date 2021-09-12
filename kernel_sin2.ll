; Compile to assembly with:
; clang -S kernel_sin2.ll -o -
; To get vectorized results:
; clang -O3 -march=native -ffast-math -funroll-loops -S kernel_sin2.ll -o -
; This seems to get the best result:
; clang -O2 -march=native -S kernel_sin2.ll -o -

target triple = "x86_64-apple-macosx11.0.0"

define void @kernel_sin1(i64 %n, double* %A, double* %B) {
    %ip = alloca i64, align 8
    store i64 0, i64* %ip, align 8
    br label %main_loop
main_loop:
    %i = load i64, i64* %ip, align 8

    %Ap = getelementptr inbounds double, double* %A, i64 %i
    %x = load double, double* %Ap, align 8
    %z = fmul double %x, %x
    %r1 = fmul double -7.3572396558796051923e-13, %z        ; S8
    %r2 = fadd double  1.6046585911173017112e-10, %r1       ; S7
    %r3 = call double @llvm.fma.f64(double %z, double %r2,
               double -2.5051823583393710429e-8)            ; S6
    %r4 = call double @llvm.fma.f64(double %z, double %r3,
               double  2.7557315514280769795e-6)            ; S5
    %r5 = call double @llvm.fma.f64(double %z, double %r4,
               double -1.9841269813888534497e-4)            ; S4
    %r6 = call double @llvm.fma.f64(double %z, double %r5,
               double  8.333333333226519387e-3)             ; S3
    %r7 = call double @llvm.fma.f64(double %z, double %r6,
               double -0.16666666666664811048)              ; S2
    %r8 = call double @llvm.fma.f64(double %z, double %r7,
               double  0.9999999999999990771)               ; S1
    %r9 = fmul double %x, %r8
    %Bp = getelementptr inbounds double, double* %B, i64 %i
    store double %r9, double* %Bp, align 8

    %i2 = add nsw i64 %i, 1
    store i64 %i2, i64* %ip, align 8
    %_11 = icmp slt i64 %i2, %n
    br i1 %_11, label %main_loop, label %epilog
epilog:
    ret void
}

declare double @llvm.fma.f64(double %a, double %b, double %c)
