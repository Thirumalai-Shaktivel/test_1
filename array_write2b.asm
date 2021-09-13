; void array_write(long n, double *B);
; Two doubles at once. ARM64 (M1)

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
        stp x2, x3, [x1,  0]
        stp x4, x5, [x1, 16]
        stp x6, x7, [x1, 32]
        stp x8, x9, [x1, 48]
        add x1, x1, 64
        cmp x1, x0
        b.ne	.main_loop
.epilog:
        ret
