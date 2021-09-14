; void array_fma2(long n, double *A, double *B);
; n must be divisible by 16
; The fastest version

section .text

%ifidn __OUTPUT_FORMAT__, macho64
%define array_fma2 _array_fma2
%endif

global array_fma2

array_fma2:
        ; Arguments on entry (x64).
        ;   rdi = n
        ;   rsi = A
        ;   rdx = B

        ; Save caller registers on stack.
        push rbx
        mov rax, 0
        align 16
.main_loop:
        ; Unroll n=4 times
        vmovaps ymm0, [rsi+8*rax] ;1 load A(i:i+3)
        vmovaps ymm1, [rsi+8*(rax+4)] ;2
        vmovaps ymm2, [rsi+8*(rax+8)] ;3
        vmovaps ymm3, [rsi+8*(rax+12)] ;4

        vfmadd213pd ymm0, ymm0, ymm0 ;1 x = x+x*x
        vfmadd213pd ymm1, ymm1, ymm1   ;2
        vfmadd213pd ymm2, ymm2, ymm2   ;3
        vfmadd213pd ymm3, ymm3, ymm3   ;4

        vfmadd213pd ymm0, ymm0, ymm0   ;1
        vfmadd213pd ymm1, ymm1, ymm1   ;2
        vfmadd213pd ymm2, ymm2, ymm2   ;3
        vfmadd213pd ymm3, ymm3, ymm3   ;4

        vfmadd213pd ymm0, ymm0, ymm0   ;1
        vfmadd213pd ymm1, ymm1, ymm1   ;2
        vfmadd213pd ymm2, ymm2, ymm2   ;3
        vfmadd213pd ymm3, ymm3, ymm3   ;4

        vfmadd213pd ymm0, ymm0, ymm0   ;1
        vfmadd213pd ymm1, ymm1, ymm1   ;2
        vfmadd213pd ymm2, ymm2, ymm2   ;3
        vfmadd213pd ymm3, ymm3, ymm3   ;4

        vmovaps [rdx+8*rax], ymm0 ;1 store B(i:i+3)
        vmovaps [rdx+8*(rax+4)], ymm1 ;2
        vmovaps [rdx+8*(rax+8)], ymm2 ;3
        vmovaps [rdx+8*(rax+12)], ymm3 ;4

        add rax, 16               ; i += 4*n (n=4)
        cmp rax, rdi
        jl .main_loop             ; jump if i < n
.epilog:
        ; Restore caller registers
        pop rbx
        ret
