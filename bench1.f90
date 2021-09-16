program bench1
implicit none
integer, parameter :: dp = kind(0.d0)
real(dp) :: t1, t2, r

call cpu_time(t1)
r = f(100000000)
call cpu_time(t2)

print *, "Time", t2-t1
print *, r

call cpu_time(t1)
r = f2(100000000)
call cpu_time(t2)

print *, "Time", t2-t1
print *, r

contains

    real(dp) function f(N) result(r)
    integer, intent(in) :: N
    integer :: i
    r = 0
    do i = 1, N
        r = r + sin(real(i,dp))
    end do
    end function

    real(dp) function f2(N) result(r)
    integer, intent(in) :: N
    integer :: i
    real(dp) :: A(N), B(N)
    do i = 1, N
        A(i) = i
    end do
    call sin1(N, A, B)
    r = sum(B)
    end function

    pure subroutine sin1(n, A, B)
    integer, value, intent(in) :: n
    real(dp), intent(in) :: A(n)
    real(dp), intent(out) :: B(n)
    real(dp), parameter :: S1 = 0.9999999999999990771_dp
    real(dp), parameter :: S2 = -0.16666666666664811048_dp
    real(dp), parameter :: S3 = 8.333333333226519387e-3_dp
    real(dp), parameter :: S4 = -1.9841269813888534497e-4_dp
    real(dp), parameter :: S5 = 2.7557315514280769795e-6_dp
    real(dp), parameter :: S6 = -2.5051823583393710429e-8_dp
    real(dp), parameter :: S7 = 1.6046585911173017112e-10_dp
    real(dp), parameter :: S8 = -7.3572396558796051923e-13_dp
    real(dp), parameter :: one_over_twopi = 1/6.283185307179586_dp
    real(dp), parameter :: p1 = 6.28318405151367188e+00_dp
    real(dp), parameter :: p2 = 1.25566566566703841e-06_dp
    real(dp), parameter :: p3 = 2.48934886875864535e-13_dp
    real(dp), parameter :: pi = 3.1415926535897932384626433832795_dp
    real(dp) :: x, z, Nd, x0
    integer :: i
    do i = 1, n
        x0 = A(i)
        x = abs(x0)
        Nd = int(x*one_over_twopi)
        x = ((x - Nd*p1) - Nd*p2) - Nd*p3
        x = min(x, pi - x)
        x = max(x, -pi - x)
        x = min(x, pi - x)
        B(i) = x * sign(1._dp, x0)
    end do
    do i = 1, n
        x = B(i)
        z = x*x
        B(i) = x * (S1+z*(S2+z*(S3+z*(S4+z*(S5+z*(S6+z*(S7+z*S8)))))))
    end do
    end subroutine

end program
