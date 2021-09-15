program sin_accuracy_pure_kernel
use, intrinsic :: iso_fortran_env, only: sp => real32, dp => real64
implicit none

real(dp), parameter :: pi = 3.1415926535897932384626433832795_dp

integer :: i, N
real(dp) :: x, xmin, xmax

N = 100

xmin = -pi/2
xmax = +pi/2


do i = 1, N
    x = (xmax-xmin)*(i-1)/(N-1) + xmin
    print "(es23.16, '   ', es23.16)", x, dsin2(x)
end do

contains

elemental real(dp) function dsin2(x) result(r)
real(dp), intent(in) :: x
real(dp) :: y
y = modulo(x, 2*pi)
y = min(y, pi - y)
y = max(y, -pi - y)
y = min(y, pi - y)
r = kernel_dsin(y)
end function

elemental integer(8) function floor2(x) result(r)
real(dp), intent(in) :: x
if (x >= 0) then
    r = x
else
    r = x-1
end if
end function

pure real(dp) function modulo_2pi_6(xh) result(zh)
real(dp), intent(in) :: xh
integer(8) :: N
real(dp) :: yh, yl, Nd, p1, p2, p3, p4, p5, p6, p7, p8, x2
if (abs(xh) < 1e16) then
    yh = 6.283185307179586_dp ! 2*pi (high)
    p1 = 6.25000000000000000e+00_dp
    p2 = 3.12500000000000000e-02_dp
    p3 = 1.89208984375000000e-03_dp
    p4 = 4.19616699218750000e-05_dp
    p5 = 1.25169754028320312e-06_dp
    p6 = 3.95812094211578369e-09_dp
    p7 = 1.00044417195022106e-11_dp
    p8 = 2.48934886875864535e-13_dp
    x2 = abs(xh)
    N = floor2(x2/yh)
    Nd = real(N,dp)
    zh = (((((((x2 - Nd*p1) - Nd*p2) - Nd*p3) - Nd*p4) - Nd*p5) - Nd*p6) - Nd*p7) - Nd*p8
    zh = zh * sign(1._dp, xh)
else
    error stop "unsupported range"
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

! Accurate on [-pi/2,pi/2] to about 1e-16
elemental real(dp) function kernel_dsin2(x) result(res)
real(dp), intent(in) :: x
real(dp), parameter :: S1 = 1
real(dp), parameter :: S2 = -0.16666666666665748417_dp
real(dp), parameter :: S3 = 8.333333333260810195e-3_dp
real(dp), parameter :: S4 = -1.9841269819408224684e-4_dp
real(dp), parameter :: S5 = 2.7557315969010714494e-6_dp
real(dp), parameter :: S6 = -2.5051843446312301534e-8_dp
real(dp), parameter :: S7 = 1.6047020166520616231e-10_dp
real(dp), parameter :: S8 = -7.360938387054769116e-13_dp
real(dp) :: z
z = x*x
res = x * (S1+z*(S2+z*(S3+z*(S4+z*(S5+z*(S6+z*(S7+z*S8)))))))
end function

end program
