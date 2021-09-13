; void array_fma2(long n, double *A, double *B);
; Vectorized version. ARM64 (M1)
; Runs at 0.5; Theoretical: 4 * fma, each fma at 0.125, total 0.5

.section	__TEXT,__text,regular,pure_instructions
.globl	_array_fma2
.p2align	2

_array_fma2:
        mov x9, 8
        mul x0, x0, x9
        add x0, x0, x1
.main_loop:
        ldr q0, [x1,   0]
        fmla.2d v0, v0, v0
        fmla.2d v0, v0, v0
        fmla.2d v0, v0, v0
        fmla.2d v0, v0, v0
        str q0, [x2,   0]

        ldr q1, [x1,   16]
        fmla.2d v1, v1, v1
        fmla.2d v1, v1, v1
        fmla.2d v1, v1, v1
        fmla.2d v1, v1, v1
        str q1, [x2,   16]

        add x1, x1, 32
        add x2, x2, 32
        cmp x1, x0
        b.ne	.main_loop
.epilog:
        ret
