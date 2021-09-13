; void array_read(long n, double *A);
; Original, simplest version. ARM64 (M1)

.section	__TEXT,__text,regular,pure_instructions
.globl	_array_read
.p2align	2

_array_read:
        mov x9, 8
        mul x0, x0, x9
        add x0, x0, x1
.main_loop:
        ldr d0, [x1, 0]
        ldr d1, [x1, 8]
        ldr d2, [x1, 16]
        ldr d3, [x1, 24]
        ldr d4, [x1, 32]
        ldr d5, [x1, 40]
        ldr d6, [x1, 48]
        ldr d7, [x1, 56]
        add x1, x1, 64
        cmp x1, x0
        b.ne	.main_loop
.epilog:
        ret
