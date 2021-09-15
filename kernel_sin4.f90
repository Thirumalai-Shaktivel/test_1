subroutine kernel_sin1(n, A, B) bind(c)
! Intel: 1.23 cycles per double; peak: 9*0.125 = 1.125
! ARM: 1.23 cycles per double
use iso_fortran_env, only: dp=>real64
use iso_c_binding, only: c_long, c_double
integer(c_long), value, intent(in) :: n
real(c_double), intent(in) :: A(n)
real(c_double), intent(out) :: B(n)
real(dp), parameter :: S1 = 0.9999999999999990771_dp
real(dp), parameter :: S2 = -0.16666666666664811048_dp
real(dp), parameter :: S3 = 8.333333333226519387e-3_dp
real(dp), parameter :: S4 = -1.9841269813888534497e-4_dp
real(dp), parameter :: S5 = 2.7557315514280769795e-6_dp
real(dp), parameter :: S6 = -2.5051823583393710429e-8_dp
real(dp), parameter :: S7 = 1.6046585911173017112e-10_dp
real(dp), parameter :: S8 = -7.3572396558796051923e-13_dp
real(dp) :: x, z
integer(c_long) :: i
do i = 1, n
    x = A(i)
    x = modulo_2pi_6(x)
    x = min(x, pi - x)
    x = max(x, -pi - x)
    x = min(x, pi - x)
    z = x*x
    B(i) = x * (S1+z*(S2+z*(S3+z*(S4+z*(S5+z*(S6+z*(S7+z*S8)))))))
end do

contains

pure real(c_double) function modulo_2pi_6(xh) result(zh)
real(c_double), intent(in) :: xh
integer(c_long) :: N
real(c_double) :: yh, yl, Nd, p1, p2, p3, p4, p5, p6, p7, p8
yh = 6.283185307179586_dp ! 2*pi (high)
p1 = 6.25000000000000000e+00_dp
p2 = 3.12500000000000000e-02_dp
p3 = 1.89208984375000000e-03_dp
p4 = 4.19616699218750000e-05_dp
p5 = 1.25169754028320312e-06_dp
p6 = 3.95812094211578369e-09_dp
p7 = 1.00044417195022106e-11_dp
p8 = 2.48934886875864535e-13_dp
N = floor(xh/yh)
Nd = real(N,dp)
zh = (((((((xh - Nd*p1) - Nd*p2) - Nd*p3) - Nd*p4) - Nd*p5) - Nd*p6) - Nd*p7) - Nd*p8
end function

end subroutine
