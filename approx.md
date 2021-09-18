# How to approximate sin(x)

sin(x) is an odd function, any odd function can be written as x times even
function. Every even function's Taylor expansion only has even powers of x.

    1) We impose the odd function f(-x) = -f(x) property onto our approximation.


So:

    sin(x) = x*P(x^2)

Where P(z) is a polynomial and z=x^2. This imposes the odd property.

It turns out this implicitly imposes matching the value at x=0. To be
consistent, we should now match the value at x=pi/2:  sin(pi/2)=1:

    2) pi/2 * P((pi/2)^2) = 1

It seems natural to either impose both, or none.

These can be our starting point.

Optionally, we can also impose any number of derivatives on each end. To impose
the first derivative at x=0 we get:

    3) P(0) = 1

To impose the derivative sin'(pi/2) = 0, we compute the derivative of sin(x):

        sin'(x) = P(z) + 2*z*P'(z)

And then evaluate at x=pi/2:

    4) P((pi/2)^2) + 2*(pi/2)^2*P'((pi/2)^2) = 0

Again it seems natural to either impose both or none. As we will see below, we
might not always have enough freedom to impose both, in that case imposing 3)
first and then 4) seems to make sense.

It seems imposing the derivatives might not actually improve the maximum
absolute (or relative) error, but it improves the smoothness at the end points.
One can keep imposing more and more derivatives at each end which fully
determines the polynomial. If we only keep imposing derivatives at x=0, we
obtain the Taylor polynomial. This has the well known property that it is
highly accurate near origin, but the accuracy deteriorates as x goes larger. If
we impose derivatives at both ends, we will get very good accuracy at both
ends, but worse accuracy in the middle. For this reason it makes sense not to
impose any derivatives besides the function value. Or possible just the first
derivatives either on both ends, or just for x=0, and use the remaining freedom
to obtain the smallest possible maximum point wise absolute error.


The condition 3) is satisfied by:

    P(z) = 1 + z*Q(z)

For any Q(z).

The condition 4) imposes the following constraint on Q(z):

    P((pi/2)^2) + 2*(pi/2)^2*P'((pi/2)^2) = 0

    (1 + (pi/2)^2 * Q((pi/2)^2)) + 2*(pi/2)^2 * (
        Q((pi/2)^2) + (pi/2)^4 * Q'((pi/2)^2)) = 0


The condition 2) imposes the following constraint on Q(z):

    pi/2 * (1 + (pi/2)^2 * Q((pi/2)^2)) = 1

Which is equivalent to:

    1 + (pi/2)^2 * Q((pi/2)^2) = 2/pi

    (pi/2)^2 * Q((pi/2)^2) = 2/pi - 1

    Q((pi/2)^2) = (2/pi - 1) / (pi/2)^2
                = (2-pi)/pi * 4 / pi^2
                = 4*(2-pi)/pi^3
                = -0.14727245910375517 = C1


We sort all possible polynomials from the simplest to more complicated:

    Q(z) = a
    Q(z) = a+b*z
    Q(z) = a+b*z+c*z^2
    Q(z) = a+b*z+c*z^2+d*z^3
    ...

And we have to impose the condition 3) on each.

Q1:

    Q(z) = a

We impose 2), but not 4):

    Q((pi/2)^2) = a = C1

    P(z) = 1 + z*Q(z) = 1 + z*C1

    sin(x) = x*P(x^2) = x*(1+z*C1)

This is the simplest possible approximation for sin(x) that satisfies
conditions 1), 2) and 3). We could relax condition 3) to get more freedom. The
conditions 1) and 2) impose the boundary values at 0 and pi/2, so we most
likely want to keep those.

Q2:

    Q(z) = a+b*z

We can impose both 2), and 4). Imposing 2):

    Q((pi/2)^2) = a+b*pi/2 = C1

so:

    a = C1-b*pi/2

and:

    Q(z) = a+b*z = C1-b*pi/2 + b*x = C1 + b*(x-pi/2)

    P(z) = 1 + z*Q(z) = 1 + z*(C1 + b*(z-pi/2))

    sin(x) = x*P(z) = x*(1+z*(C1-b*pi/2 + z*b))
                    = x*(1+z*(C1-b*pi/2) + b*z^2)

Now we impose 4)

    sin'(x) = (1+z*(C1-b*pi/2) + b*z^2)
        + 2*z*(C1-b*pi/2 + 2*b*z)

For x=pi/2, z = pi^2/4 we can set this to 0 and obtain a linear equation for
`b` to solve.

This fully determines this polynomial.

-------------

It seems we can do better for these simpler (as well as more complicated)
polynomials by not imposing the first derivative, and rather trying to achieve
the best possible maximum error. From now on, we will only impose the value
conditions at x=0 and x=pi/2, so 1) and 2). Note that the condition 1) is
equivalent to the odd property and so it makes sense to impose at least that.

Condition 1) is imposed by:

    1) sin(x) = x*P(x^2)

Condition 2) is imposed by:

    2) pi/2 * P((pi/2)^2) = 1

The possible polynomials P(z) are:

    P(z) = a
    P(z) = a+b*z
    P(z) = a+b*z+c*z^2
    P(z) = a+b*z+c*z^2+d*z^3

P1:

    P(z) = a

    pi/2 * P((pi/2)^2) = 1

    pi/2 * a = 1

    a = 2/pi

    P(z) = 2/pi

    sin(x) = x*2/pi

That is a linear function connecting the two end points. Trully the simplest
approximation.

P2:

    P(z) = a + b*z

    pi/2 * P((pi/2)^2) = 1

    pi/2 * (a + b*(pi/2)^2) = 1

    a = 2/pi - b*(pi/2)^2

    P(z) = a + b*z = (2/pi - b*(pi/2)^2) + b*z

    sin(x) = x*P(z) = x * ((2/pi - b*(pi/2)^2) + z*b)

We now have one free parameter `b` to optimize for the best error.

P3:

    P(z) = a + b*z + c*z^2

    pi/2 * P((pi/2)^2) = 1

    pi/2 * (a + b*(pi/2)^2 + c*(pi/2)^4) = 1

    a = 2/pi - b*(pi/2)^2 - c*(pi/2)^4

    P(z) = a + b*z + c*z^2 = (2/pi-b*(pi/2)^2-c*(pi/2)^4) + b*z + c*z^2

    sin(x) = x*P(z) = x * (2/pi-b*(pi/2)^2-c*(pi/2)^4 + b*z + c*z^2)

We now have two free parameters `b` and `c` to optimize for the best error.
