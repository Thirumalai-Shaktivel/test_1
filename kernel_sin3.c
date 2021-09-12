void kernel_sin1(long n, double *A, double *B) {
    const double S1 = 0.9999999999999990771;
    const double S2 = -0.16666666666664811048;
    const double S3 = 8.333333333226519387e-3;
    const double S4 = -1.9841269813888534497e-4;
    const double S5 = 2.7557315514280769795e-6;
    const double S6 = -2.5051823583393710429e-8;
    const double S7 = 1.6046585911173017112e-10;
    const double S8 = -7.3572396558796051923e-13;
    long i;
    for (i=0; i<n; i++) {
        double x = A[i];
        double z = x*x;
        B[i] = x * (S1+z*(S2+z*(S3+z*(S4+z*(S5+z*(S6+z*(S7+z*S8)))))));
    }
}
