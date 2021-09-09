program sin_perf_pure_vec
use, intrinsic :: iso_fortran_env, only: dp => real64
use sin_perf_pure_vec2, only: array_copy, pi
implicit none

integer, parameter :: sizes(*) = [ &
    8, 16, 32, 64, 128, 1024, 1024*1024, 1024*1024*10]

integer :: i, j, N, Ntile, k, M, u
real(dp) :: alpha, beta, a, xmin, xmax
real(dp) :: t1, t2
real(dp), allocatable :: x(:)
real(dp), allocatable :: r(:)

xmin = -pi/2
xmax = pi/2

do j = 1, size(sizes)
    Ntile = sizes(j)
    M = 1024*100000 / Ntile
    if (M == 0) M = 1
    N = M * Ntile
    allocate(r(N), x(N))
    call random_number(x)
    x = x*(xmax-xmin)+xmin

    call cpu_time(t1)
    do k = 1, N, Ntile
        call array_copy(Ntile, x(k:k+Ntile-1), r(k:k+Ntile-1))
        !r(i) = x(i)
        !r(i) = kernel_dsin(x(i))
        !r(i) = dsin2(x(i))
    end do
    call cpu_time(t2)
    print "(i10, i10, es15.6)", Ntile, M, (t2-t1)/N
    ! To prevent the compiler to optimize out the above loop
    open(newunit=u, file="log.txt", status="replace", action="write")
    write(u, *) r(1:10)
    close(u)

    deallocate(r, x)
end do

end program
