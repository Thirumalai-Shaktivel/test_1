program sin_accuracy_pure
use, intrinsic :: iso_fortran_env, only: sp => real32, dp => real64
implicit none

real(dp), parameter :: pi = 3.1415926535897932384626433832795_dp

integer :: i, N
real(dp) :: x, alpha, beta, a, xmin, xmax

N = 100

xmin = 1e-20_dp
xmax = 5e9_dp
a = 1e20_dp

beta = log(a) / (N-1)
alpha = (xmax - xmin) / (exp(beta*N) - 1)


do i = 1, N+1
    x = alpha * (exp(beta*(i-1)) - 1) + xmin
    print "(es23.16, '   ', es25.16e3, '   ', es25.16e3)", x, dsin1(x), dsin3(x)
end do

contains

elemental integer(8) function floor2(x) result(r)
real(dp), intent(in) :: x
if (x >= 0) then
    r = x
else
    r = x-1
end if
end function


elemental real(dp) function dsin1(x) result(r)
real(dp), intent(in) :: x
real(dp) :: y
y = modulo(x, 2*pi)
y = min(y, pi - y)
y = max(y, -pi - y)
y = min(y, pi - y)
r = kernel_dsin(y)
end function

elemental real(dp) function dsin2(x) result(r)
real(dp), intent(in) :: x
real(dp) :: y
y = modulo_2pi_6(x)
y = min(y, pi - y)
y = max(y, -pi - y)
y = min(y, pi - y)
r = kernel_dsin(y)
end function

real(dp) function dsin3(x) result(r)
real(dp), intent(in) :: x
real(dp) :: y
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

pure real(dp) function dd_add1(xh, yh, yl) result(r)
real(dp), intent(in) :: xh, yh, yl
real(dp) :: zh, zl
call renormalize(zh, zl, xh, yh)
r = zh+(zl+yl)
end function

pure subroutine renormalize(zh, zl, xh, xl)
real(dp), intent(out) :: zh, zl
real(dp), intent(in) :: xh, xl
zh = xh+xl
zl = xh-zh+xl
end subroutine

pure subroutine split(zh, zl, xh)
real(dp), intent(out) :: zh, zl
real(dp), intent(in) :: xh
real(dp), parameter :: c = 2**27+1 ! = 134217729._dp
real(dp) :: up
up = xh*c
zh = (xh-up)+up
zl = xh-zh
end subroutine

pure subroutine dd_mul(zh, zl, xh, xl, yh, yl)
real(dp), intent(out) :: zh, zl
real(dp), intent(in) :: xh, xl, yh, yl
real(dp) :: zh0, zl0, u1, u2, v1, v2
call split(u1, u2, xh)
call split(v1, v2, yh)
zh0 = xh*yh
zl0 = (((u1*v1-zh0)+(u1*v2))+(u2*v1))+(u2*v2)
zl0 = zl0 + xh*yl + xl*yh
call renormalize(zh, zl, zh0, zl0)
end subroutine

pure real(dp) function modulo_2pi(xh) result(zh)
real(dp), intent(in) :: xh
integer(8) :: N
real(dp) :: yh, yl, zl
if (abs(xh) < 1e16) then
    yh = 6.283185307179586_dp ! 2*pi (high)
    yl = 2.4492935982947064e-16_dp ! 2*pi (low)
    N = floor2(xh/yh)
    call dd_mul(zh, zl, -real(N,dp), 0._dp, yh, yl)
    zh = dd_add1(xh, zh, zl)
else
    error stop "unsupported range"
end if
end function

pure real(dp) function modulo_2pi_2(xh) result(zh)
real(dp), intent(in) :: xh
integer(8) :: N
real(dp) :: yh, yl, Nd, p1, p2, p3
if (abs(xh) < 1e16) then
    yh = 6.283185307179586_dp ! 2*pi (high)
    p1 = 6.28318405151367188e+00_dp
    p2 = 1.25566566566703841e-06_dp
    p3 = 2.48934886875864535e-13_dp
    N = floor2(xh/yh)
    Nd = real(N,dp)
    zh = ((xh - Nd*p1) - Nd*p2) - Nd*p3
else
    error stop "unsupported range"
end if
end function

pure real(dp) function modulo_2pi_3(xh) result(zh)
real(dp), intent(in) :: xh
integer(8) :: N
real(dp) :: yh, yl, Nd, p1, p2, p3, p4, p5, p6
if (abs(xh) < 1e16) then
    yh = 6.283185307179586_dp ! 2*pi (high)
    p1 = 6.28125000000000000e+00_dp
    p2 = 1.93405151367187500e-03_dp
    p3 = 1.25542283058166504e-06_dp
    p4 = 2.42835085373371840e-10_dp
    p5 = 2.48689957516035065e-13_dp
    p6 = 2.44929359829470641e-16_dp
    N = floor2(xh/yh)
    Nd = real(N,dp)
    zh = (((((xh - Nd*p1) - Nd*p2) - Nd*p3) - Nd*p4) - Nd*p5) - Nd*p6
else
    error stop "unsupported range"
end if
end function

pure real(dp) function modulo_2pi_4(xh) result(zh)
real(dp), intent(in) :: xh
integer(8) :: N
real(dp) :: yh, yl, Nd, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, &
    p13, p14, p15, p16, p17, p18, p19, p20, p21, p22, p23, p24
if (abs(xh) < 1e16) then
    yh = 6.283185307179586_dp ! 2*pi (high)
p1 = 4.00000000000000000e+00_dp
p2 = 2.00000000000000000e+00_dp
p3 = 2.50000000000000000e-01_dp
p4 = 3.12500000000000000e-02_dp
p5 = 9.76562500000000000e-04_dp
p6 = 4.88281250000000000e-04_dp
p7 = 2.44140625000000000e-04_dp
p8 = 1.22070312500000000e-04_dp
p9 = 6.10351562500000000e-05_dp
p10 = 3.05175781250000000e-05_dp
p11 = 7.62939453125000000e-06_dp
p12 = 3.81469726562500000e-06_dp
p13 = 9.53674316406250000e-07_dp
p14 = 2.38418579101562500e-07_dp
p15 = 5.96046447753906250e-08_dp
p16 = 3.72529029846191406e-09_dp
p17 = 2.32830643653869629e-10_dp
p18 = 7.27595761418342590e-12_dp
p19 = 1.81898940354585648e-12_dp
p20 = 9.09494701772928238e-13_dp
p21 = 2.27373675443232059e-13_dp
p22 = 1.42108547152020037e-14_dp
p23 = 7.10542735760100186e-15_dp
p24 = 2.44929359829470641e-16_dp
    N = floor2(xh/yh)
    Nd = real(N,dp)
    zh = (((((((((((((((((((((((xh - Nd*p1) - Nd*p2) - Nd*p3) - Nd*p4) &
        - Nd*p5) - Nd*p6) - Nd*p7) - Nd*p8) - Nd*p9) - Nd*p10) - Nd*p11) &
        - Nd*p12) - Nd*p13) - Nd*p14) - Nd*p15) - Nd*p16) - Nd*p17) &
        - Nd*p18) - Nd*p19) - Nd*p20) - Nd*p21) - Nd*p22) - Nd*p23) &
        - Nd*p24
else
    error stop "unsupported range"
end if
end function

pure real(dp) function modulo_2pi_5(xh) result(zh)
real(dp), intent(in) :: xh
integer(8) :: N
real(dp) :: yh, yl, Nd, p1, p2, p3, p4
if (abs(xh) < 1e16) then
    yh = 6.283185307179586_dp ! 2*pi (high)
    p1 = 6.28222656250000000e+00_dp
    p2 = 9.58681106567382812e-04_dp
    p3 = 6.35627657175064087e-08_dp
    p4 = 1.02533766063780756e-11_dp
    N = floor2(xh/yh)
    Nd = real(N,dp)
    zh = (((xh - Nd*p1) - Nd*p2) - Nd*p3) - Nd*p4
else
    error stop "unsupported range"
end if
end function

pure real(dp) function modulo_2pi_6(xh) result(zh)
real(dp), intent(in) :: xh
integer(8) :: N
real(dp) :: yh, yl, Nd, p1, p2, p3, p4, p5, p6, p7, p8, x2
if (abs(xh) < 1e16) then
    yh = 6.283185307179586_dp ! 2*pi (high)
    p1 = 6.25000000000000000e+00_dp
    p2 = 3.12500000000000000e-02_dp
    p3 = 1.89208984375000000e-03_dp
    p4 = 4.19616699218750000e-05_dp
    p5 = 1.25169754028320312e-06_dp
    p6 = 3.95812094211578369e-09_dp
    p7 = 1.00044417195022106e-11_dp
    p8 = 2.48934886875864535e-13_dp
    x2 = abs(xh)
    N = floor2(x2/yh)
    Nd = real(N,dp)
    zh = (((((((x2 - Nd*p1) - Nd*p2) - Nd*p3) - Nd*p4) - Nd*p5) - Nd*p6) - Nd*p7) - Nd*p8
    zh = zh * sign(1._dp, xh)
else
    error stop "unsupported range"
end if
end function

pure subroutine kernel_sin1(n, A, B) bind(c)
! Intel: 1.23 cycles per double; peak: 9*0.125 = 1.125
! ARM: 1.23 cycles per double
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
real(dp), parameter :: one_over_twopi = 1/6.283185307179586_dp
real(dp), parameter :: p1 = 6.28318405151367188e+00_dp
real(dp), parameter :: p2 = 1.25566566566703841e-06_dp
real(dp), parameter :: p3 = 2.48934886875864535e-13_dp
real(dp), parameter :: pi = 3.1415926535897932384626433832795_dp
real(dp) :: x, z, Nd
integer(c_long) :: i
do i = 1, n
    x = A(i)
    Nd = int(x*one_over_twopi)
    x = ((x - Nd*p1) - Nd*p2) - Nd*p3
    ! If A(i)>0, then 0 < x < 2*pi
    ! If A(i)<0, then -2*pi < x < 0
    x = min(x, pi - x)
    x = max(x, -pi - x)
    x = min(x, pi - x)
    ! Now always -pi/2 < x < +pi/2 and sin(x)=sin(A(i))
    B(i) = x
end do
do i = 1, n
    x = B(i)
    z = x*x
    B(i) = x * (S1+z*(S2+z*(S3+z*(S4+z*(S5+z*(S6+z*(S7+z*S8)))))))
end do
end subroutine

pure subroutine kernel_sin2(n, A, B) bind(c)
use iso_fortran_env, only: dp=>real64
use iso_c_binding, only: c_long, c_double
implicit none
integer(c_long), value, intent(in) :: n
real(c_double), intent(in) :: A(n)
real(c_double), intent(out) :: B(n)
real(dp), parameter ::     c9 = -7.97255955009037868891952e-18_dp
real(dp), parameter ::     c8 =  2.81009972710863200091251e-15_dp
real(dp), parameter ::     c7 = -7.64712219118158833288484e-13_dp
real(dp), parameter ::     c6 =  1.60590430605664501629054e-10_dp
real(dp), parameter ::     c5 = -2.50521083763502045810755e-08_dp
real(dp), parameter ::     c4 =  2.75573192239198747630416e-06_dp
real(dp), parameter ::     c3 = -0.000198412698412696162806809_dp
real(dp), parameter ::     c2 =  0.00833333333333332974823815_dp
real(dp), parameter ::     c1 = -0.166666666666666657414808_dp
real(dp), parameter :: S1 = 1
real(dp), parameter :: S2 = c1
real(dp), parameter :: S3 = c2
real(dp), parameter :: S4 = c3
real(dp), parameter :: S5 = c4
real(dp), parameter :: S6 = c5
real(dp), parameter :: S7 = c6
real(dp), parameter :: S8 = c7
real(dp), parameter :: S9 = c8
real(dp), parameter :: S10 = c9
real(dp), parameter :: p1 = 3.14159202575683594e+00_dp
real(dp), parameter :: p2 = 6.27832832833519205e-07_dp
real(dp), parameter :: p3 = 1.24467443437932268e-13_dp
real(dp), parameter :: pi = 3.1415926535897932384626433832795_dp
real(dp), parameter :: one_over_pi = 1/pi
real(dp) :: x, z, Nd
integer(c_long) :: i
do i = 1, n
    x = A(i)
    Nd = nint(x*one_over_pi)
    x = ((x - Nd*p1) - Nd*p2) - Nd*p3
    ! -pi/2 < x < pi/2
    ! For even Nd, we have sin(A(i)) = sin(x)
    ! For odd Nd,  we have sin(A(i)) = sin(x+pi) = -sin(x) = sin(-x)
    if (modulo(int(Nd), 2) == 1) x = -x
    B(i) = x
end do
do i = 1, n
    x = B(i)
    z = x*x
    B(i) = x*(S1+z*(S2+z*(S3+z*(S4+z*(S5+z*(S6+z*(S7+z*(S8+z*(S9+z*S10)))))))))
end do
end subroutine

subroutine kernel_sin3(n, A, B) bind(c)
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
real(dp) :: x, z, Nd
integer(c_long) :: i
do i = 1, n
    x = A(i)
    Nd = nint(x*one_over_pi)
    x = ((x - Nd*p1) - Nd*p2) - Nd*p3
    ! -pi/2 < x < pi/2
    ! For even Nd, we have sin(A(i)) = sin(x)
    ! For odd Nd,  we have sin(A(i)) = sin(x+pi) = -sin(x) = sin(-x)
    !if (modulo(int(Nd), 2) == 1) x = -x
    if (and(int(Nd), 1) /= 0) x = -x
    B(i) = x
end do
do i = 1, n
    x = B(i)
    z = x*x
    B(i) = x * (S1+z*(S2+z*(S3+z*(S4+z*(S5+z*(S6+z*(S7+z*S8)))))))
end do
end subroutine


subroutine kernel_sin4(n, A, B) bind(c)
! Intel: runs at 1.545 cycles; Peak:: 1.458
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


end program
