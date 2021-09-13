; void array_write(long n, double *B);
; Vectorized version. ARM64 (M1)

.section	__TEXT,__text,regular,pure_instructions
.globl	_array_write
.p2align	2

_array_write:
        mov x9, 8
        mul x0, x0, x9
        add x0, x0, x1
.main_loop:
        ; x1 ... pointer &B(i), we are processing B(i:i+3)
        ; x0 ... ending condition pointer, ends when x1 == x0
        str q1, [x1,   0]
        str q2, [x1,  16]
        str q3, [x1,  32]
        str q4, [x1,  48]
        str q5, [x1,  64]
        str q6, [x1,  80]
        str q7, [x1,  96]
        str q8, [x1, 112]
        add x1, x1, 128
        cmp x1, x0
        b.ne	.main_loop
.epilog:
        ret
