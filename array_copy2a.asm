; void array_copy2(long n, double *A, double *B);
; Original, simplest version

section .text

%ifidn __OUTPUT_FORMAT__, macho64
%define array_copy2 _array_copy2
%endif

global array_copy2

array_copy2:
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
        vmovaps [rdx+8*rax], ymm0 ; store B(i:i+3)
        add rax, 4                ; i += 4
        cmp rax, rdi
        jl .main_loop             ; jump if i < n
.epilog:
        ; Restore caller registers
        pop rbx
        ret
