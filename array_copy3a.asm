; void array_copy2(long n, double *A, double *B);
; Original, simplest version. ARM64 (M1)

.section	__TEXT,__text,regular,pure_instructions
.globl	_array_copy2
.p2align	2

_array_copy2:
.main_loop:
        ldr	d0, [x1], #8
        str	d0, [x2], #8
        subs	x0, x0, #1
        b.ne	.main_loop
.epilog:
        ret
