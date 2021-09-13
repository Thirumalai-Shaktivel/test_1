; void array_copy2(long n, double *A, double *B);
; Vectorized version. ARM64 (M1)
; Runs at about 0.32; We would expect to run at 0.25 (W).
; Idea: there are 4 store/load units, two for load, one for store and one for
; both. Assuming the "both" unit is 50% for write, then we have W: 1.5 units,
; R: 2.5 units. The speed is then 1/1.5/2 = 0.333 cycles. For only writes we
; get 1/2/2 = 0.25 cycles. For only reads we get 1/3/2 = 0.1667

.section	__TEXT,__text,regular,pure_instructions
.globl	_array_copy2
.p2align	2

_array_copy2:
        mov x9, 8
        mul x0, x0, x9
        add x0, x0, x1
.main_loop:
        ldr q0, [x1,   0]
        ldr q1, [x1,  16]
        ldr q2, [x1,  32]
        ldr q3, [x1,  48]
        ldr q4, [x1,  64]

        str q0, [x2,   0]
        ldr q5, [x1,  80]
        str q1, [x2,  16]
        ldr q6, [x1,  96]
        str q2, [x2,  32]
        ldr q7, [x1, 112]

        str q3, [x2,  48]
        str q4, [x2,  64]
        str q5, [x2,  80]
        str q6, [x2,  96]
        str q7, [x2, 112]

        add x1, x1, 128
        add x2, x2, 128
        cmp x1, x0
        b.ne	.main_loop
.epilog:
        ret
