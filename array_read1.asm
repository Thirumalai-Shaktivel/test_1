; void array_read(long n, double *A);
; n must be divisible by 64
; Loop unrolled version

section .text

%ifidn __OUTPUT_FORMAT__, macho64
%define array_read _array_read
%endif

global array_read

array_read:
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
        vmovups ymm0,  [rsi+8*(rax+ 0)] ; load  A(i   :i+ 3)
        vmovups ymm1,  [rsi+8*(rax+ 4)] ; load  A(i+ 4:i+ 7)
        vmovups ymm2,  [rsi+8*(rax+ 8)] ; load  A(i+ 8:i+11)
        vmovups ymm3,  [rsi+8*(rax+12)] ; load  A(i+12:i+15)
        vmovups ymm4,  [rsi+8*(rax+16)]
        vmovups ymm5,  [rsi+8*(rax+20)]
        vmovups ymm6,  [rsi+8*(rax+24)]
        vmovups ymm7,  [rsi+8*(rax+28)]
        vmovups ymm8,  [rsi+8*(rax+32)]
        vmovups ymm9,  [rsi+8*(rax+36)]
        vmovups ymm10, [rsi+8*(rax+40)]
        vmovups ymm11, [rsi+8*(rax+44)]
        vmovups ymm12, [rsi+8*(rax+48)]
        vmovups ymm13, [rsi+8*(rax+52)]
        vmovups ymm14, [rsi+8*(rax+56)]
        vmovups ymm15, [rsi+8*(rax+60)]
        add rax, 64               ; i += 64 (=n*4)
        cmp rax, rdi
        jl .main_loop             ; jump if i < n
.epilog:
        ; Restore caller registers
        pop rbx
        ret
