program sin_perf_pure
use, intrinsic :: iso_fortran_env, only: sp => real32, dp => real64
use b, only: dd_mul, dd_add1
implicit none

real(dp), parameter :: pi = 3.1415926535897932384626433832795_dp

integer :: i, N, k, M
real(dp) :: alpha, beta, a, xmin, xmax
real(dp) :: t1, t2
real(dp), volatile :: x, r

N = 100
M = 1000000

xmin = 1e-20_dp
xmax = 1e16_dp
a = 1e20_dp

beta = log(a) / (N-1)
alpha = (xmax - xmin) / (exp(beta*N) - 1)


do i = 1, N+1
    x = alpha * (exp(beta*(i-1)) - 1) + xmin
    call cpu_time(t1)
    do k = 1, M
        r = dsin2(x)
    end do
    call cpu_time(t2)
    print "(es23.16, '   ', es25.16e3, '   ', es15.6)", x, dsin2(x), (t2-t1)/M
end do

contains

elemental real(dp) function dsin1(x) result(r)
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

elemental integer(8) function floor2(x) result(r)
real(dp), intent(in) :: x
if (x >= 0) then
    r = x
else
    r = x-1
end if
end function

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
