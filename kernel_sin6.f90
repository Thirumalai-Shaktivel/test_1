subroutine kernel_sin1(n, A, B) bind(c)
! Intel: runs at 2.5 cycles; Peak:: 1.458
use iso_fortran_env, only: dp=>real64
use iso_c_binding, only: c_long, c_double
implicit none
integer(c_long), value, intent(in) :: n
real(c_double), intent(in) :: A(n)
real(c_double), intent(out) :: B(n)
real(dp), parameter :: S1 =  0.982396485658623
real(dp), parameter :: S2 = -0.14013802346642243
real(dp), parameter :: pi = 3.1415926535897932384626433832795_dp
real(dp), parameter :: one_over_pi = 1/pi
real(dp) :: x, z, Nd
integer(c_long) :: i, xi
equivalence (x,xi)
do i = 1, n
    x = A(i)
    Nd = int(x*one_over_pi + 0.5_dp)
    x = x - Nd*pi
    ! -pi/2 < x < pi/2
    ! For even Nd, we have sin(A(i)) = sin(x)
    ! For odd Nd,  we have sin(A(i)) = sin(x+pi) = -sin(x) = sin(-x)
    ! Preferred way, but slow:
    !if (modulo(int(Nd), 2) == 1) x = -x
    ! Floating point and integer representation dependent, but fast:
    xi = xor(shiftl(int(Nd, c_long),63), xi)
    z = x*x
    B(i) = x*(S1+z*S2)
end do
end subroutine
