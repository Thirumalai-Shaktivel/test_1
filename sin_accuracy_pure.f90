program sin_accuracy_pure
use, intrinsic :: iso_fortran_env, only: sp => real32, dp => real64
implicit none

real(dp), parameter :: pi = 3.1415926535897932384626433832795_dp

integer :: i, N
real(dp) :: x, alpha, beta, a, xmin, xmax

N = 100

xmin = 1e-20_dp
xmax = 1e16_dp
a = 1e20_dp

beta = log(a) / (N-1)
alpha = (xmax - xmin) / (exp(beta*N) - 1)


do i = 1, N+1
    x = alpha * (exp(beta*(i-1)) - 1) + xmin
    print "(es23.16, '   ', es23.16)", x, dsin2(x)
end do

contains


pure real(dp) function abs(x) result(r)
real(dp), intent(in) :: x
if (x >= 0) then
    r = x
else
    r = -x
end if
end function

elemental integer function floor(x) result(r)
real(dp), intent(in) :: x
if (x >= 0) then
    r = x
else
    r = x-1
end if
end function

elemental integer(8) function floor2(x) result(r)
real(dp), intent(in) :: x
if (x >= 0) then
    r = x
else
    r = x-1
end if
end function

elemental real(dp) function modulo(x, y) result(r)
real(dp), intent(in) :: x, y
r = x-floor(x/y)*y
end function

elemental real(dp) function min(x, y) result(r)
real(dp), intent(in) :: x, y
if (x < y) then
    r = x
else
    r = y
end if
end function

elemental real(dp) function max(x, y) result(r)
real(dp), intent(in) :: x, y
if (x > y) then
    r = x
else
    r = y
end if
end function

elemental real(dp) function dsin(x) result(r)
real(dp), intent(in) :: x
real(dp) :: y
y = modulo(x, 2*pi)
y = min(y, pi - y)
y = max(y, -pi - y)
y = min(y, pi - y)
r = kernel_dsin(y)
end function

elemental real(dp) function dsin2(x) result(r)
real(dp), intent(in) :: x
real(dp) :: y
y = modulo_2pi(x)
y = min(y, pi - y)
y = max(y, -pi - y)
y = min(y, pi - y)
r = kernel_dsin(y)
end function

! Accurate on [-pi/2,pi/2] to about 1e-16
elemental real(dp) function kernel_dsin(x) result(res)
real(dp), intent(in) :: x
real(dp), parameter :: S1 = 0.9999999999999990771_dp
real(dp), parameter :: S2 = -0.16666666666664811048_dp
real(dp), parameter :: S3 = 8.333333333226519387e-3_dp
real(dp), parameter :: S4 = -1.9841269813888534497e-4_dp
real(dp), parameter :: S5 = 2.7557315514280769795e-6_dp
real(dp), parameter :: S6 = -2.5051823583393710429e-8_dp
real(dp), parameter :: S7 = 1.6046585911173017112e-10_dp
real(dp), parameter :: S8 = -7.3572396558796051923e-13_dp
real(dp) :: z
z = x*x
res = x * (S1+z*(S2+z*(S3+z*(S4+z*(S5+z*(S6+z*(S7+z*S8)))))))
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

end program
