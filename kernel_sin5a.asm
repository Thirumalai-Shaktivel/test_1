; void kernel_sin1(long n, double *A, double *B);
; Vectorized version. ARM64 (M1)
; Runs at 0.5; Theoretical: 4 * fma, each fma at 0.125, total 0.5


.section __TEXT,__literal8,8byte_literals
.p2align 3

S1: .quad 0x3feffffffffffff8 ; double 0.9999999999999990771
S2: .quad 0xbfc55555555552b9 ; double -0.16666666666664812
S3: .quad 0x3f8111111110208b ; double 0.0083333333332265193
S4: .quad 0xbf2a01a019677b7b ; double -1.9841269813888535E-4
S5: .quad 0x3ec71de371212827 ; double 2.7557315514280768E-6
S6: .quad 0xbe5ae6315d6ba572 ; double -2.5051823583393709E-8
S7: .quad 0x3de60de3f77343c0 ; double 1.6046585911173016E-10
S8: .quad 0xbd69e2cff677919d ; double -7.3572396558796053E-13

.section	__TEXT,__text,regular,pure_instructions
.globl	_kernel_sin1
.p2align	2

_kernel_sin1:
        mov x9, 8
        mul x0, x0, x9
        add x0, x0, x1

        adrp x11, S1@PAGE
        ldr  x12, [x11, S1@PAGEOFF]
        dup.2d v8, x12

        adrp x11, S2@PAGE
        ldr  x12, [x11, S2@PAGEOFF]
        dup.2d v9, x12

        adrp x11, S3@PAGE
        ldr  x12, [x11, S3@PAGEOFF]
        dup.2d v10, x12

        adrp x11, S4@PAGE
        ldr  x12, [x11, S4@PAGEOFF]
        dup.2d v11, x12

        adrp x11, S5@PAGE
        ldr  x12, [x11, S5@PAGEOFF]
        dup.2d v12, x12

        adrp x11, S6@PAGE
        ldr  x12, [x11, S6@PAGEOFF]
        dup.2d v13, x12

        adrp x11, S7@PAGE
        ldr  x12, [x11, S7@PAGEOFF]
        dup.2d v14, x12

        adrp x11, S8@PAGE
        ldr  x12, [x11, S8@PAGEOFF]
        dup.2d v15, x12
.main_loop:
        ;vmovapd ymm0, [rsi+8*rax] ; x = load A(i:i+3)
        ldr q0, [x1, 0]

        ; vmulpd ymm1, ymm0, ymm0   ; r = x*x
        fmul.2d v1, v0, v0

        ; vmovapd ymm2, ymm1        ; z = r
        mov.16b	v2, v1

        ; vfmadd213pd ymm1, ymm15, ymm14 ; r = S7+z*S8
        fmla.2d v1, v15, v14
        ;vfmadd213pd ymm1, ymm2, ymm13 ; r = S6+z*r
        fmla.2d v1, v2, v13
        ;vfmadd213pd ymm1, ymm2, ymm12 ; r = S5+z*r
        fmla.2d v1, v2, v12
        ;vfmadd213pd ymm1, ymm2, ymm11 ; r = S4+z*r
        fmla.2d v1, v2, v11
        ;vfmadd213pd ymm1, ymm2, ymm10 ; r = S3+z*r
        fmla.2d v1, v2, v10
        ;vfmadd213pd ymm1, ymm2, ymm9 ; r = S2+z*r
        fmla.2d v1, v2, v9
        ;vfmadd213pd ymm1, ymm2, ymm8 ; r = S1+z*r
        fmla.2d v1, v2, v8
        ;vmulpd ymm1, ymm1, ymm0   ; r = x*r
        fmla.2d v1, v2, v0

        ; vmovapd [rdx+8*rax], ymm1 ; store B(i:i+3) = r
        str q1, [x2, 0]

        add x1, x1, 16
        add x2, x2, 16
        cmp x1, x0
        b.ne	.main_loop
.epilog:
        ret
