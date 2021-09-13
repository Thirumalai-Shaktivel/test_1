; void array_mul2(long n, double *A, double *B);
; Vectorized version. ARM64 (M1)
; Runs at about ??; We would expect to run at 0.5 (twice 0.25 for mul).

.section	__TEXT,__text,regular,pure_instructions
.globl	_array_mul2
.p2align	2

_array_mul2:
        mov x9, 8
        mul x0, x0, x9
        add x0, x0, x1
.main_loop:
        ldr q0, [x1,   0]
        str q0, [x2,   0]

        add x1, x1, 16
        add x2, x2, 16
        cmp x1, x0
        b.ne	.main_loop
.epilog:
        ret
