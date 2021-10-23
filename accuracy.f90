program accuracy
use, intrinsic :: iso_fortran_env, only: dp => real64
use sin_implementations, only: dsin1, dsin3b, dsin4
implicit none

integer :: i, N
real(dp) :: x, alpha, beta, a, xmin, xmax

N = 100

xmin = 1e-10_dp
xmax = 5e9_dp
a = 1e20_dp

beta = log(a) / (N-1)
alpha = (xmax - xmin) / (exp(beta*N) - 1)

do i = 1, N+1
    x = alpha * (exp(beta*(i-1)) - 1) + xmin
    print "(es23.16, 8(' ', es25.16e3))", x, &
        dsin1( x), dsin3b( x), dsin4( x), sin( x), &
        dsin1(-x), dsin3b(-x), dsin4(-x), sin(-x)
end do

end program accuracy
