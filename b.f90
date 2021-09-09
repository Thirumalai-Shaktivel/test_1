module b
use, intrinsic :: iso_fortran_env, only: sp => real32, dp => real64
implicit none

real(dp), parameter :: pi = 3.1415926535897932384626433832795_dp

contains

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

end module
