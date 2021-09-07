program sin_accuracy
implicit none
integer, parameter :: dp = kind(0.d0)

integer :: i, N
real(dp) :: x, alpha, beta, a, xmin, xmax

N = 100

!xmin = 1e-20_dp
!xmax = 1e30_dp
!a = 1e40_dp
xmin = 1e-20_dp
xmax = 1e10_dp
a = 1e20_dp

beta = log(a) / (N-1)
alpha = (xmax - xmin) / (exp(beta*N) - 1)


do i = 1, N+1
    x = alpha * (exp(beta*(i-1)) - 1) + xmin
    print "(es23.16, '   ', es23.16)", x, sin(x)
end do
end program
