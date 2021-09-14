; void array_mul2(long n, double *A, double *B);
; n must be divisible by 8
; The fastest version

section .text

%ifidn __OUTPUT_FORMAT__, macho64
%define array_mul2 _array_mul2
%endif

global array_mul2

array_mul2:
        ; Arguments on entry (x64).
        ;   rdi = n
        ;   rsi = A
        ;   rdx = B

        ; Save caller registers on stack.
        push rbx
        mov rax, 0
        align 16
.main_loop:
        vmovaps ymm0, [rsi+8*rax] ; load A(i:i+3)
        vmulpd ymm0, ymm0, ymm0   ; x = x*x
        vmulpd ymm0, ymm0, ymm0   ; x = x*x
        vmulpd ymm0, ymm0, ymm0   ; x = x*x
        vmulpd ymm0, ymm0, ymm0   ; x = x*x
        vmovaps [rdx+8*rax], ymm0 ; store B(i:i+3)

        vmovaps ymm1, [rsi+8*(rax+4)] ;2
        vmulpd ymm1, ymm1, ymm1   ;2
        vmulpd ymm1, ymm1, ymm1   ;2
        vmulpd ymm1, ymm1, ymm1   ;2
        vmulpd ymm1, ymm1, ymm1   ;2
        vmovaps [rdx+8*(rax+4)], ymm1 ;2

        add rax, 8                ; i += 8
        cmp rax, rdi
        jl .main_loop             ; jump if i < n
.epilog:
        ; Restore caller registers
        pop rbx
        ret
