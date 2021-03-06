program benchmark
use, intrinsic :: iso_fortran_env, only: dp => real64, i8 => int64
use sin_implementations, only: array_read, array_write, kernel_sin1, &
        kernel_sin4, kernel_gfortran_sin, kernel_sin42pi
implicit none

integer :: j, k, M, u
integer(i8) :: Ntile
! The sizes must be divisible by 512 (=64 doubles)
integer(i8), parameter :: sizes(*) = [ &
    512, &
    1024, &         ! 1 KB
    2 * 1024, &
    4 * 1024, &
    3 * 1024, &
    6 * 1024, &
    8 * 1024, &
    10 * 1024, &
    16 * 1024, &
    32 * 1024, &
    64 * 1024, &
    96 * 1024, &
    128 * 1024, &
    196 * 1024, &
    256 * 1024, &
    400 * 1024, &
    512 * 1024, &
    600 * 1024, &
    800 * 1024, &
    900 * 1024, &
    1024 * 1024, &    ! 1 MB
    1400 * 1024, &
    1800 * 1024, &
    2 * 1024 * 1024, &
    4 * 1024 * 1024, &
    8 * 1024 * 1024, &
    16 * 1024 * 1024, & ! 16 MB
    32 * 1024 * 1024  &
]
real(dp), parameter :: pi = 3.1415926535897932384626433832795_dp
real(dp) :: xmin, xmax
real(dp) :: t1, t2, time_kernel, time_read, time_write
real(dp), allocatable :: x(:)
real(dp), allocatable :: r(:)
integer, parameter :: &
    benchmark_type_fast = 1, &
    benchmark_type_fastest = 2, &
    benchmark_type_gfortran_sin = 3, &
    benchmark_type_fastest2 = 4
integer :: benchmark_type
character(len=32) :: arg

call get_command_argument(1, arg)
if (len_trim(arg) == 0) error stop "Provide benchmark type number as an argument"
arg = trim(arg)
read(arg, *) benchmark_type

xmin = -pi/2
xmax = pi/2

do j = 1, size(sizes)
    Ntile = sizes(j) / 8 ! Double precision (8 bytes) as array element size
    M = 1024*10000*6*10*2 / Ntile
    if (Ntile > 32768) M = M / 5
    if (M == 0) M = 1
    allocate(r(Ntile), x(Ntile))
    call random_number(x)
    x = x*(xmax-xmin)+xmin

    call cpu_time(t1)
    do k = 1, M
        call array_read(Ntile, x)
    end do
    call cpu_time(t2)
    time_read = (t2-t1)/(M*Ntile)

    call cpu_time(t1)
    do k = 1, M
        call array_write(Ntile, r)
    end do
    call cpu_time(t2)
    time_write = (t2-t1)/(M*Ntile)

    call cpu_time(t1)
    if (benchmark_type == benchmark_type_fast) then
        ! This is the fast high accuracy version, the candidate for inclusion
        ! into LFortran's runtime library
        do k = 1, M
            call kernel_sin1(Ntile, x, r)
        end do
    elseif (benchmark_type == benchmark_type_fastest) then
        ! This is the fastest possible but low accuracy version
        ! It still uses (-pi/2, pi/2) reduction
        do k = 1, M
            call kernel_sin4(Ntile, x, r)
        end do
    elseif (benchmark_type == benchmark_type_fastest2) then
        ! This is the fastest possible but low accuracy version
        ! It uses (-pi, pi) reduction
        do k = 1, M
            call kernel_sin42pi(Ntile, x, r)
        end do
    elseif (benchmark_type == benchmark_type_gfortran_sin) then
        ! The default gfortran sin
        do k = 1, M
            call kernel_gfortran_sin(Ntile, x, r)
        end do
    else
        error stop "Benchmark type not implemented"
    end if
    call cpu_time(t2)
    time_kernel = (t2-t1)/(M*Ntile)

    print "(i10, i10, es15.6, es15.6, es15.6)", Ntile, M, time_kernel, time_read, time_write
    ! To prevent the compiler to optimize out the above loop
    open(newunit=u, file="log.txt", status="replace", action="write")
    write(u, *) r(1:10)
    close(u)

    deallocate(r, x)
end do

end program
