; void array_write(long n, double *B);
; Vectorized version, two quads at a time. ARM64 (M1)
; The STP with Q (128 bit) registers takes 1 cycle, twice as long
; Thus the array_write2c version is as efficient.

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
        stp q1, q2, [x1,   0]
        stp q3, q4, [x1,  32]
        stp q5, q6, [x1,  64]
        stp q7, q8, [x1,  96]
        add x1, x1, 128
        cmp x1, x0
        b.ne	.main_loop
.epilog:
        ret
