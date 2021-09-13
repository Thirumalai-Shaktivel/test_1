; void kernel_sin1(long n, double *A, double *B);
; Unrolled loop. ARM64 (M1)


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
        dup.2d v16, x12

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
        ldr q0, [x1, 0]
        fmul.2d v1, v0, v0
        mov.16b	v2, v1
        mov.16b	v17, v14
        fmla.2d v17, v2, v15
        mov.16b	v18, v13
        fmla.2d v18, v2, v17
        mov.16b	v17, v12
        fmla.2d v17, v2, v18
        mov.16b	v18, v11
        fmla.2d v18, v2, v17
        mov.16b	v17, v10
        fmla.2d v17, v2, v18
        mov.16b	v18, v9
        fmla.2d v18, v2, v17
        mov.16b	v17, v16
        fmla.2d v17, v2, v18
        fmul.2d v1, v17, v0
        str q1, [x2, 0]

        ldr q20, [x1, 16]
        fmul.2d v21, v20, v20
        mov.16b	v22, v21
        mov.16b	v23, v14
        fmla.2d v23, v22, v15
        mov.16b	v24, v13
        fmla.2d v24, v22, v23
        mov.16b	v23, v12
        fmla.2d v23, v22, v24
        mov.16b	v24, v11
        fmla.2d v24, v22, v23
        mov.16b	v23, v10
        fmla.2d v23, v22, v24
        mov.16b	v24, v9
        fmla.2d v24, v22, v23
        mov.16b	v23, v16
        fmla.2d v23, v22, v24
        fmul.2d v21, v23, v20
        str q21, [x2, 16]

        add x1, x1, 32
        add x2, x2, 32
        cmp x1, x0
        b.ne	.main_loop
.epilog:
        ret
