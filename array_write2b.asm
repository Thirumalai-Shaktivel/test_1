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
        stp d0, d1, [x1,  0]
        stp d2, d3, [x1, 16]
        stp d4, d5, [x1, 32]
        stp d6, d7, [x1, 48]
        stp d8, d9, [x1, 64]
        stp d10, d11, [x1, 80]
        stp d12, d13, [x1, 96]
        stp d14, d15, [x1, 112]
        add x1, x1, 128
        cmp x1, x0
        b.ne	.main_loop
.epilog:
        ret
