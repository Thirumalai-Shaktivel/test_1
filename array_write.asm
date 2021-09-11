; void array_write(long n, double *A);
; n must be divisible by 64
; Loop unrolled version

section .text

%ifidn __OUTPUT_FORMAT__, macho64
%define array_write _array_write
%endif

global array_write

array_write:
        ; Arguments on entry (x64).
        ;   rdi = n
        ;   rsi = A

        ; Save caller registers on stack.
        push rbx
        mov rax, 0
        align 16
.main_loop:
        ; Loop variable: rax = i
        ; Each double is 8 bytes, so we use 8*rax to access the first one
        ; Each ymm register stores 4 doubles, we operate on 4 doubles at a time
        ; We unroll the loop n=16 times
        vmovaps [rsi+8*(rax+ 0)], ymm0 ; store B(i   :i+ 3)
        vmovaps [rsi+8*(rax+ 4)], ymm1 ; store B(i+ 4:i+ 7)
        vmovaps [rsi+8*(rax+ 8)], ymm2 ; store B(i+ 8:i+11)
        vmovaps [rsi+8*(rax+12)], ymm3 ; store B(i+12:i+15)
        vmovaps [rsi+8*(rax+16)], ymm4
        vmovaps [rsi+8*(rax+20)], ymm5
        vmovaps [rsi+8*(rax+24)], ymm6
        vmovaps [rsi+8*(rax+28)], ymm7
        vmovaps [rsi+8*(rax+32)], ymm8
        vmovaps [rsi+8*(rax+36)], ymm9
        vmovaps [rsi+8*(rax+40)], ymm10
        vmovaps [rsi+8*(rax+44)], ymm11
        vmovaps [rsi+8*(rax+48)], ymm12
        vmovaps [rsi+8*(rax+52)], ymm13
        vmovaps [rsi+8*(rax+56)], ymm14
        vmovaps [rsi+8*(rax+60)], ymm15
        add rax, 64               ; i += 64 (=n*4)
        cmp rax, rdi
        jl .main_loop             ; jump if i < n
.epilog:
        ; Restore caller registers
        pop rbx
        ret
