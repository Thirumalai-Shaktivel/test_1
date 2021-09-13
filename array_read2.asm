; void array_read(long n, double *A);
; Original, simplest version. ARM64 (M1)

.section	__TEXT,__text,regular,pure_instructions
.globl	_array_read
.p2align	2

_array_read:
        mov x9, #0
        add x10, x1, #0
        add x11, x1, #1
        add x12, x1, #2
        add x13, x1, #3
.main_loop:
        ldr d0, [x10, x9, lsl #3]
        ldr d1, [x11, x9, lsl #3]
        ldr d2, [x12, x9, lsl #3]
        ldr d3, [x13, x9, lsl #3]
        add x9, x9, #4
        cmp x9, x0
        b.ne	.main_loop
.epilog:
        ret
