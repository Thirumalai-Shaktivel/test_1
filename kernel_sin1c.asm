; void kernel_sin1(long n, double *A, double *B);
; n must be divisible by 8
; Unrolled version 2x

section .text

%ifidn __OUTPUT_FORMAT__, macho64
%define kernel_sin1 _kernel_sin1
%endif

global kernel_sin1

kernel_sin1:
        ; Arguments on entry (x64).
        ;   rdi = n
        ;   rsi = A
        ;   rdx = B

        ; Save caller registers on stack.
        push rbx

        vbroadcastsd ymm8, [S1]
        vbroadcastsd ymm9, [S2]
        vbroadcastsd ymm10, [S3]
        vbroadcastsd ymm11, [S4]
        vbroadcastsd ymm12, [S5]
        vbroadcastsd ymm13, [S6]
        vbroadcastsd ymm14, [S7]
        vbroadcastsd ymm15, [S8]

        mov rax, 0
        align 16
.main_loop:
        ; Loop unrolled n=2 times
        ; Register allocations
        ; xmm8-15 ... Constants S1 - S8
        ; Body 1
        ; ymm0 ... x
        ; ymm1 ... r  ! result
        ; ymm2 ... z = x*x
        ; Body 2
        ; ymm3 ... x
        ; ymm4 ... r  ! result
        ; ymm5 ... z = x*x
        vmovapd ymm0, [rsi+8*(rax+0)]  ;1 x = load A(i:i+3)
        vmovapd ymm3, [rsi+8*(rax+4)]  ;2 x = load A(i+4:i+7)
        vmulpd ymm1, ymm0, ymm0        ;1 r = x*x
        vmulpd ymm4, ymm3, ymm3        ;2 r = x*x
        vmovapd ymm2, ymm1             ;1 z = r
        vmovapd ymm5, ymm4             ;2 z = r
        vfmadd213pd ymm1, ymm15, ymm14 ;1 r = S7+z*S8
        vfmadd213pd ymm4, ymm15, ymm14 ;2 r = S7+z*S8
        vfmadd213pd ymm1, ymm2, ymm13  ;1 r = S6+z*r
        vfmadd213pd ymm4, ymm5, ymm13  ;2 r = S6+z*r
        vfmadd213pd ymm1, ymm2, ymm12  ;1 r = S5+z*r
        vfmadd213pd ymm4, ymm5, ymm12  ;2 r = S5+z*r
        vfmadd213pd ymm1, ymm2, ymm11  ;1 r = S4+z*r
        vfmadd213pd ymm4, ymm5, ymm11  ;2 r = S4+z*r
        vfmadd213pd ymm1, ymm2, ymm10  ;1 r = S3+z*r
        vfmadd213pd ymm4, ymm5, ymm10  ;2 r = S3+z*r
        vfmadd213pd ymm1, ymm2, ymm9   ;1 r = S2+z*r
        vfmadd213pd ymm4, ymm5, ymm9   ;2 r = S2+z*r
        vfmadd213pd ymm1, ymm2, ymm8   ;1 r = S1+z*r
        vfmadd213pd ymm4, ymm5, ymm8   ;2 r = S1+z*r
        vmulpd ymm1, ymm1, ymm0        ;1 r = x*r
        vmulpd ymm4, ymm4, ymm3        ;2 r = x*r
        vmovapd [rdx+8*(rax+0)], ymm1  ;1 store B(i:i+3) = r
        vmovapd [rdx+8*(rax+4)], ymm4  ;2 store B(i+4:i+7) = r

        add rax, 8                ; i += 8 (=n*4)
        cmp rax, rdi
        jl .main_loop             ; jump if i < n
.epilog:
        ; Restore caller registers
        pop rbx
        ret


section .data
default rel

S1: dq 0.9999999999999990771
S2: dq -0.16666666666664811048
S3: dq 8.333333333226519387e-3
S4: dq -1.9841269813888534497e-4
S5: dq 2.7557315514280769795e-6
S6: dq -2.5051823583393710429e-8
S7: dq 1.6046585911173017112e-10
S8: dq -7.3572396558796051923e-13
