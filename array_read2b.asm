; void array_read(long n, double *A);
; Using SIMD, two doubles. ARM64 (M1)

.section	__TEXT,__text,regular,pure_instructions
.globl	_array_read
.p2align	2

_array_read:
        mov x9, 8
        mul x0, x0, x9
        add x0, x0, x1
.main_loop:
        ldr q0, [x1, 0]
        ldr q1, [x1, 16]
        ldr q2, [x1, 32]
        ldr q3, [x1, 48]
        ldr q4, [x1, 64]
        ldr q5, [x1, 80]
        ldr q6, [x1, 96]
        ldr q7, [x1, 112]
        add x1, x1, 128
        cmp x1, x0
        b.ne	.main_loop
.epilog:
        ret
