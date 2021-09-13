; void array_read(long n, double *A);
; Original, simplest version. ARM64 (M1)

.section	__TEXT,__text,regular,pure_instructions
.globl	_array_read
.p2align	2

_array_read:
;        mov x11, #8
;        mul x0, x0, x11
.main_loop:
        ldr d0, [x1]
        ldr d1, [x1, #8]
        ldr d2, [x1, #16]
        ldr d3, [x1, #24]
        add x1, x1, #32
;        cmp x1, x0
        subs x0, x0, #4
        b.ne	.main_loop
.epilog:
        ret
