module b
use, intrinsic :: iso_fortran_env, only: sp => real32, dp => real64
implicit none

real(dp), parameter :: pi = 3.1415926535897932384626433832795_dp

contains

pure subroutine split(zh, zl, xh)
real(dp), intent(out) :: zh, zl
real(dp), intent(in) :: xh
real(dp), parameter :: c = 2**27+1 ! = 134217729._dp
real(dp) :: up
up = xh*c
zh = (xh-up)
zh = zh + up
zl = xh-zh
end subroutine

end module
