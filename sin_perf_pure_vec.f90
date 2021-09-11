program sin_perf_pure_vec
use, intrinsic :: iso_fortran_env, only: dp => real64, i8 => int64
use sin_perf_pure_vec2, only: array_copy, pi, array_kernel_sin1, &
        array_kernel_sin2, array_copy2, array_read
implicit none

! The sizes must be divisible by 512 (=64 doubles)
integer(i8), parameter :: sizes(*) = [ &
    512, &
    1024, & ! 1 KB
    2 * 1024, &
    4 * 1024, &
    3 * 1024, &
    6 * 1024, &
    8 * 1024, &
    10 * 1024, &
    16 * 1024, &
    32*1024, &
    64*1024, &
    96*1024, &
    128*1024, &
    196*1024, &
    256*1024, &
    400*1024, &
    512*1024, &
    600*1024, &
    800*1024, &
    900*1024, &
    1024*1024, & ! 1 MB
    1400*1024, &
    1800*1024, &
    2 * 1024*1024, &
    4 * 1024*1024, &
    8 * 1024*1024, &
    16 * 1024*1024, & ! 16 MB
    32 * 1024*1024, &
    64 * 1024*1024 &
!    128 * 1024*1024, &
!    1024*1024*1024, & ! 1 GB
!    2 * 1024*1024*1024, &
!    4 * 1024*1024*1024 & ! 4 GB
    ]

integer :: i, j, k, M, u
integer(i8) :: Ntile
real(dp) :: alpha, beta, a, xmin, xmax
real(dp) :: t1, t2
real(dp), allocatable :: x(:)
real(dp), allocatable :: r(:)

xmin = -pi/2
xmax = pi/2

! Test for correctness
!Ntile = 64
!allocate(r(Ntile), x(Ntile))
!call random_number(x)
!print *, x
!print *, r
!call array_copy2(Ntile, x, r)
!print *, x
!print *, r
!deallocate(r, x)
!stop

do j = 1, size(sizes)
    Ntile = sizes(j) / 8 ! Double precision (8 bytes) as array element size
    M = 1024*10000*6 / Ntile
    if (M == 0) M = 1
    allocate(r(Ntile), x(Ntile))
    call random_number(x)
    x = x*(xmax-xmin)+xmin

    call cpu_time(t1)
    do k = 1, M
        !call array_copy(Ntile, x(k:k+Ntile-1), r(k:k+Ntile-1))
        !call array_copy2(Ntile, x, r)
        call array_read(Ntile, x)
        !call array_kernel_sin1(Ntile, x, r)
        !call array_kernel_sin2(Ntile, x, r)
        !r(i) = x(i)
        !r(i) = kernel_dsin(x(i))
        !r(i) = dsin2(x(i))
    end do
    call cpu_time(t2)
    print "(i10, i10, es15.6)", Ntile, M, (t2-t1)/(M*Ntile)
    ! To prevent the compiler to optimize out the above loop
    open(newunit=u, file="log.txt", status="replace", action="write")
    write(u, *) r(1:10)
    close(u)

    deallocate(r, x)
end do

end program
