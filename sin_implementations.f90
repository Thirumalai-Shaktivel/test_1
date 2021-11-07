module sin_implementations
use iso_c_binding, only: c_long, c_double
use, intrinsic :: iso_fortran_env, only: dp => real64, i8 => int64
implicit none

real(dp), parameter :: pi = 3.1415926535897932384626433832795_dp

interface
    subroutine array_read(n, A) bind(c)
    import :: c_long, c_double
    integer(c_long), value, intent(in) :: n
    real(c_double), intent(in) :: A(n)
    end subroutine

    subroutine array_write(n, B) bind(c)
    import :: c_long, c_double
    integer(c_long), value, intent(in) :: n
    real(c_double), intent(out) :: B(n)
    end subroutine
end interface

contains

elemental real(dp) function dsin1(x) result(r)
real(dp), intent(in) :: x
real(dp) :: y
integer :: N
N = nint(x/pi)
y = x-N*pi
if (modulo(N, 2) == 1) y = -y
r = kernel_dsin(y)
end function

real(dp) function dsin3b(x) result(r)
real(dp), intent(in) :: x
real(dp) :: A(1), B(1)
A(1) = x
call kernel_sin3b(1_8, A, B)
r = B(1)
end function

real(dp) function dsin4(x) result(r)
real(dp), intent(in) :: x
real(dp) :: A(1), B(1)
A(1) = x
call kernel_sin4(1_8, A, B)
r = B(1)
end function

! Accurate on [-pi/2,pi/2] to about 1e-16
elemental real(dp) function kernel_dsin(x) result(res)
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

subroutine kernel_sin3b(n, A, B) bind(c)
implicit none
integer(c_long), value, intent(in) :: n
real(c_double), intent(in) :: A(n)
real(c_double), intent(out) :: B(n)
real(dp), parameter :: p1 = 3.14159202575683594e+00_dp
real(dp), parameter :: p2 = 6.27832832833519205e-07_dp
real(dp), parameter :: p3 = 1.24467443437932268e-13_dp
real(dp) :: x, Nd
integer(c_long) :: i, xi
equivalence (x,xi)
do i = 1, n
    x = A(i)
    Nd = int(x/pi + 0.5_dp*sign(1._dp, x))
    x = ((x - Nd*p1) - Nd*p2) - Nd*p3
    xi = xor(shiftl(int(Nd, c_long),63), xi)
    B(i) = x
end do
do i = 1, n
    B(i) = kernel_dsin(B(i))
end do
end subroutine

subroutine kernel_sin4(n, A, B) bind(c)
! Intel: runs at 1.545 cycles; Peak:: 1.458
implicit none
integer(c_long), value, intent(in) :: n
real(c_double), intent(in) :: A(n)
real(c_double), intent(out) :: B(n)
real(dp), parameter :: S1 =  0.982396485658623
real(dp), parameter :: S2 = -0.14013802346642243
real(dp) :: x, z, Nd
integer(c_long) :: i, xi
equivalence (x,xi)
do i = 1, n
    x = A(i)
    ! Nd = nint(x/pi)
    Nd = int(x/pi + 0.5_dp*sign(1._dp, x))
    x = x - Nd*pi
    ! -pi/2 < x < pi/2
    ! For even Nd, we have sin(A(i)) = sin(x)
    ! For odd Nd,  we have sin(A(i)) = sin(x+pi) = -sin(x) = sin(-x)
    ! Preferred way, but slow:
    ! if (modulo(int(Nd), 2) == 1) x = -x
    ! Floating point and integer representation dependent, but fast:
    xi = xor(shiftl(int(Nd, c_long),63), xi)
    z = x*x
    B(i) = x*(S1+z*S2)
end do
end subroutine


subroutine kernel_sin1(n, A, B)
! Intel: 2.83 cycles per double; peak: 2.458
! ARM: 2.5 cycles per double; peak: 2.125
use iso_fortran_env, only: dp=>real64
use iso_c_binding, only: c_long, c_double
implicit none
integer(c_long), value, intent(in) :: n
real(c_double), intent(in) :: A(n)
real(c_double), intent(out) :: B(n)
real(dp), parameter :: p1 = 3.14159202575683594e+00_dp
real(dp), parameter :: p2 = 6.27832832833519205e-07_dp
real(dp), parameter :: p3 = 1.24467443437932268e-13_dp
real(dp), parameter :: pi = 3.1415926535897932384626433832795_dp
real(dp), parameter :: one_over_pi = 1/pi
real(dp) :: x, z, Nd
integer(c_long) :: i, xi
equivalence (x,xi)
do i = 1, n
    x = A(i)
    !Nd = nint(x*one_over_pi)
    Nd = int(x/pi + 0.5_dp*sign(1._dp, x))
    x = ((x - Nd*p1) - Nd*p2) - Nd*p3
    ! -pi/2 < x < pi/2
    ! For even Nd, we have sin(A(i)) = sin(x)
    ! For odd Nd,  we have sin(A(i)) = sin(x+pi) = -sin(x) = sin(-x)
    !if (modulo(int(Nd), 2) == 1) x = -x
    !if (and(int(Nd), 1) /= 0) x = -x
    xi = xor(shiftl(int(Nd, c_long),63), xi)
    B(i) = x
end do
do i = 1, n
    B(i) = kernel_dsin(B(i))
end do

contains

    ! Accurate on [-pi/2,pi/2] to about 1e-16
    elemental real(dp) function kernel_dsin(x) result(res)
    use iso_fortran_env, only: dp=>real64
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

end subroutine


end module sin_implementations
