program sin_perf_pure_vec
use, intrinsic :: iso_fortran_env, only: sp => real32, dp => real64
!use b, only: split
implicit none

real(dp), parameter :: pi = 3.1415926535897932384626433832795_dp

integer :: i, N, k, M
real(dp) :: alpha, beta, a, xmin, xmax
real(dp) :: t1, t2
real(dp), allocatable :: r(:), x(:)

N = 1024
M = 100000

allocate(r(N), x(N))
xmin = -pi/2
xmax = pi/2
!do i = 1, N
!    x(i) = xmin + (xmax-xmin)*(i-1)/(N-1)
!end do
call random_number(x)
x = x*(xmax-xmin)+xmin

call cpu_time(t1)
do k = 1, M
    do i = 1, N
        !r(i) = kernel_dsin(x(i))
        r(i) = dsin2(x(i))
    end do
    x = r
end do
call cpu_time(t2)
print "(i4, '   ', es15.6, '   ', es15.6)", N, (t2-t1)/M, (t2-t1)/M/N


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

real(dp) function dsin2(x) result(r)
real(dp), intent(in) :: x
real(dp) :: y
if (abs(x) < pi/2) then
    r = kernel_dsin(x)
else
    y = modulo_2pi(x)
    y = min(y, pi - y)
    y = max(y, -pi - y)
    y = min(y, pi - y)
    r = kernel_dsin(y)
end if
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

real(dp) function dd_add1(xh, yh, yl) result(r)
real(dp), intent(in) :: xh, yh, yl
real(dp) :: zh, zl
call renormalize(zh, zl, xh, yh)
r = zh+(zl+yl)
end function

subroutine dd_mul(zh, zl, xh)
real(dp), intent(out) :: zh, zl
real(dp), intent(in) :: xh
real(dp) :: zh0, zl0, u1, u2
real(dp), parameter :: yh = 6.283185307179586_dp ! 2*pi (high)
real(dp), parameter :: yl = 2.4492935982947064e-16_dp ! 2*pi (low)
real(dp), parameter :: v1 =  6.2831853628158569_dp
real(dp), parameter :: v2 = -5.5636270701597823e-8_dp
call split(u1, u2, xh)
zh0 = xh*yh
zl0 = (((u1*v1-zh0)+(u1*v2))+(u2*v1))+(u2*v2)
zl0 = zl0 + xh*yl
call renormalize(zh, zl, zh0, zl0)
end subroutine

subroutine renormalize(zh, zl, xh, xl)
real(dp), volatile, intent(out) :: zh, zl
real(dp), intent(in) :: xh, xl
zh = xh+xl
zl = xh-zh+xl
end subroutine

subroutine split(zh, zl, xh)
real(dp), volatile, intent(out) :: zh, zl
real(dp), intent(in) :: xh
real(dp), parameter :: c = 2**27+1 ! = 134217729._dp
real(dp), volatile :: up
up = xh*c
zh = (xh-up)
zh = zh+up
zl = xh-zh
end subroutine

real(dp) function modulo_2pi(xh) result(zh)
real(dp), intent(in) :: xh
integer(8) :: N
real(dp) :: zl
real(dp), parameter :: yh = 6.283185307179586_dp ! 2*pi (high)
N = floor2(xh/yh)
call dd_mul(zh, zl, -real(N,dp))
zh = dd_add1(xh, zh, zl)
end function

end program
