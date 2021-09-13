; void array_write(long n, double *B);
; Original, simplest version. ARM64 (M1)

.section	__TEXT,__text,regular,pure_instructions
.globl	_array_write
.p2align	2

_array_write:
        mov x9, 8
        mul x0, x0, x9
        add x0, x0, x1
.main_loop:
        str x14, [x1, 0]
        str x15, [x1, 8]
        str x8,  [x1, 16]
        str x7,  [x1, 24]
        add x1, x1, 32
        cmp x1, x0
        b.ne	.main_loop
.epilog:
        ret
