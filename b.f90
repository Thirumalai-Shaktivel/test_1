module b
use, intrinsic :: iso_fortran_env, only: sp => real32, dp => real64
implicit none

real(dp), parameter :: pi = 3.1415926535897932384626433832795_dp

contains

elemental integer(8) function floor2(x) result(r)
real(dp), intent(in) :: x
if (x >= 0) then
    r = x
else
    r = x-1
end if
end function

pure real(dp) function dd_add1(xh, yh, yl) result(r)
real(dp), intent(in) :: xh, yh, yl
real(dp) :: zh, zl
call renormalize(zh, zl, xh, yh)
r = zh+(zl+yl)
end function

pure subroutine renormalize(zh, zl, xh, xl)
real(dp), intent(out) :: zh, zl
real(dp), intent(in) :: xh, xl
zh = xh+xl
zl = xh-zh+xl
end subroutine

pure subroutine split(zh, zl, xh)
real(dp), intent(out) :: zh, zl
real(dp), intent(in) :: xh
real(dp), parameter :: c = 2**27+1 ! = 134217729._dp
real(dp) :: up
up = xh*c
zh = (xh-up)+up
zl = xh-zh
end subroutine

pure subroutine dd_mul(zh, zl, xh, xl, yh, yl)
real(dp), intent(out) :: zh, zl
real(dp), intent(in) :: xh, xl, yh, yl
real(dp) :: zh0, zl0, u1, u2, v1, v2
call split(u1, u2, xh)
call split(v1, v2, yh)
zh0 = xh*yh
zl0 = (((u1*v1-zh0)+(u1*v2))+(u2*v1))+(u2*v2)
zl0 = zl0 + xh*yl + xl*yh
call renormalize(zh, zl, zh0, zl0)
end subroutine

pure real(dp) function modulo_2pi(xh) result(zh)
real(dp), intent(in) :: xh
integer(8) :: N
real(dp) :: yh, yl, zl
if (abs(xh) < 1e16) then
    yh = 6.283185307179586_dp ! 2*pi (high)
    yl = 2.4492935982947064e-16_dp ! 2*pi (low)
    N = floor2(xh/yh)
    call dd_mul(zh, zl, -real(N,dp), 0._dp, yh, yl)
    zh = dd_add1(xh, zh, zl)
else
    error stop "unsupported range"
end if
end function

end module
