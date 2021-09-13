; void kernel_sin1(long n, double *A, double *B);
; Vectorized version. ARM64 (M1)
; Runs at 0.5; Theoretical: 4 * fma, each fma at 0.125, total 0.5

.section	__TEXT,__text,regular,pure_instructions
.globl	_kernel_sin1
.p2align	2

_kernel_sin1:
        mov x9, 8
        mul x0, x0, x9
        add x0, x0, x1
.main_loop:
        ;vmovapd ymm0, [rsi+8*rax] ; x = load A(i:i+3)
        ldr q0, [x1, 0]

        ; vmulpd ymm1, ymm0, ymm0   ; r = x*x
        fmul.2d v1, v0, v0

        ; vmovapd ymm2, ymm1        ; z = r
        mov.16b	v2, v1

        ; vfmadd213pd ymm1, ymm15, ymm14 ; r = S7+z*S8
        fmla.2d v1, v15, v14
        ;vfmadd213pd ymm1, ymm2, ymm13 ; r = S6+z*r
        fmla.2d v1, v2, v13
        ;vfmadd213pd ymm1, ymm2, ymm12 ; r = S5+z*r
        fmla.2d v1, v2, v12
        ;vfmadd213pd ymm1, ymm2, ymm11 ; r = S4+z*r
        fmla.2d v1, v2, v11
        ;vfmadd213pd ymm1, ymm2, ymm10 ; r = S3+z*r
        fmla.2d v1, v2, v10
        ;vfmadd213pd ymm1, ymm2, ymm9 ; r = S2+z*r
        fmla.2d v1, v2, v9
        ;vfmadd213pd ymm1, ymm2, ymm8 ; r = S1+z*r
        fmla.2d v1, v2, v8
        ;vmulpd ymm1, ymm1, ymm0   ; r = x*r
        fmla.2d v1, v2, v0

        ; vmovapd [rdx+8*rax], ymm1 ; store B(i:i+3) = r
        str q1, [x2, 0]

        add x1, x1, 16
        add x2, x2, 16
        cmp x1, x0
        b.ne	.main_loop
.epilog:
        ret
