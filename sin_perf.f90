program sin_perf
implicit none
integer, parameter :: dp = kind(0.d0)

integer :: i, N, k, M
real(dp) :: alpha, beta, a, xmin, xmax
real(dp) :: t1, t2
real(dp), volatile :: x, r

N = 100
M = 1000000

! Orig:
!xmin = 1e-20_dp
!xmax = 1e30_dp
!a = 1e40_dp
xmin = 1e-20_dp
xmax = 1e16_dp
a = 1e20_dp

beta = log(a) / (N-1)
alpha = (xmax - xmin) / (exp(beta*N) - 1)


do i = 1, N+1
    x = alpha * (exp(beta*(i-1)) - 1) + xmin
    call cpu_time(t1)
    do k = 1, M
        r = sin(x)
    end do
    call cpu_time(t2)
    print "(es23.16e3, '   ', es23.16, '   ', es15.6)", x, sin(x), (t2-t1)/M
end do
end program
