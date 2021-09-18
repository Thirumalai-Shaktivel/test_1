subroutine kernel_sin1(n, A, B) bind(c)
! Intel: 3.65 cycles per double; peak: 2.5
! ARM: 3.26 cycles per double; peak: 2.25
use iso_fortran_env, only: dp=>real64
use iso_c_binding, only: c_long, c_double
implicit none
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
real(dp), parameter :: p1 = 3.14159202575683594e+00_dp
real(dp), parameter :: p2 = 6.27832832833519205e-07_dp
real(dp), parameter :: p3 = 1.24467443437932268e-13_dp
real(dp), parameter :: pi = 3.1415926535897932384626433832795_dp
real(dp), parameter :: one_over_pi = 1/pi
real(dp) :: x, z
real(dp) :: Nd
integer(c_long) :: i, xi
equivalence (x,xi)
do i = 1, n
    x = A(i)
    Nd = nint(x*one_over_pi)
    x = ((x - Nd*p1) - Nd*p2) - Nd*p3
    ! -pi/2 < x < pi/2
    ! For even Nd, we have sin(A(i)) = sin(x)
    ! For odd Nd,  we have sin(A(i)) = sin(x+pi) = -sin(x) = sin(-x)
    !if (modulo(int(Nd), 2) == 1) x = -x
    !if (and(Nd, 1) /= 0) x = -x
    xi = xor(shiftl(int(Nd, c_long),63), xi)
    B(i) = x
end do
do i = 1, n
    x = B(i)
    z = x*x
    B(i) = x * (S1+z*(S2+z*(S3+z*(S4+z*(S5+z*(S6+z*(S7+z*S8)))))))
end do
end subroutine
