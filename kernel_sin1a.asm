; void kernel_sin1(long n, double *A, double *B);
; n must be divisible by 4
; Original, simplest version

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

        vbroadcastsd ymm7, [one_over_twopi]
        vbroadcastsd ymm6, [pi]
        vbroadcastsd ymm5, [mpi]
        vbroadcastsd ymm4, [p1]
        vbroadcastsd ymm3, [p2]

        mov rax, 0
        align 16
.main_loop:
        vmovapd ymm0, [rsi+8*rax] ; x = load A(i:i+3)
        vmulpd ymm1, ymm0, ymm7   ; x = x/(2*pi)
        vcvttpd2dq xmm1, ymm1 ; x = floor(x) ! double -> int
        vcvtdq2pd ymm1, xmm1  ; x = floor(x) ! int -> double
        vfnmadd213pd ymm0, ymm1, ymm4 ; x = x-Nd*p1
        vfnmadd213pd ymm0, ymm1, ymm3 ; x = x-Nd*p2
        vfnmadd213pd ymm0, ymm1, [p3] ; x = x-Nd*p3
        vsubpd	ymm0, ymm6, ymm1 ; pi-x
        vminpd  ymm0, ymm1, ymm0 ; x = min(x, pi-x)
        vsubpd	ymm1, ymm5, ymm0 ; -pi-x
        vmaxpd  ymm1, ymm1, ymm1 ; x = min(x, -pi-x)
        vsubpd	ymm0, ymm6, ymm1 ; pi-x
        vminpd  ymm0, ymm1, ymm0 ; x = min(x, pi-x)
        vmulpd ymm1, ymm0, ymm0   ; r = x*x
        vmovapd ymm2, ymm1        ; z = r
        vfmadd213pd ymm1, ymm15, ymm14 ; r = S7+z*S8
        vfmadd213pd ymm1, ymm2, ymm13 ; r = S6+z*r
        vfmadd213pd ymm1, ymm2, ymm12 ; r = S5+z*r
        vfmadd213pd ymm1, ymm2, ymm11 ; r = S4+z*r
        vfmadd213pd ymm1, ymm2, ymm10 ; r = S3+z*r
        vfmadd213pd ymm1, ymm2, ymm9 ; r = S2+z*r
        vfmadd213pd ymm1, ymm2, ymm8 ; r = S1+z*r
        vmulpd ymm1, ymm1, ymm0   ; r = x*r
        vmovapd [rdx+8*rax], ymm1 ; store B(i:i+3) = r
        add rax, 4                ; i += 4
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
pi: dq 3.1415926535897932384626433832795
mpi: dq -3.1415926535897932384626433832795
one_over_twopi: dq 0.15915494309189535
p1: dq 6.28318405151367188e+00
p2: dq 1.25566566566703841e-06
p3: dq 2.48934886875864535e-13
