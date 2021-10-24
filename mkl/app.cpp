#include <chrono>
#include <iostream>
#include <vector>
#include <math.h>
#include <mkl.h>

const std::vector<int> sizes = {
    512,
    1024, // 1 KB
    2 * 1024,
    4 * 1024,
    3 * 1024,
    6 * 1024,
    8 * 1024,
    10 * 1024,
    16 * 1024,
    32*1024,
    64*1024,
    96*1024,
    128*1024,
    196*1024,
    256*1024,
    400*1024,
    512*1024,
    600*1024,
    800*1024,
    900*1024,
    1024*1024, // 1 MB
    1400*1024,
    1800*1024,
    2 * 1024*1024,
    4 * 1024*1024,
    8 * 1024*1024,
    16 * 1024*1024, // 16 MB
    32 * 1024*1024
//    64 * 1024*1024,
//    128 * 1024*1024
//    1024*1024*1024, // 1 GB
//    2 * 1024*1024*1024,
//    4 * 1024*1024*1024 // 4 GB
};


int main() {
    int n = 16;
    int i, j, k, M, Ntile;
    double xmin, xmax;
    xmin = -M_PI/2;
    xmax = M_PI/2;
    for(j=0; j<sizes.size(); j++) {
        Ntile = sizes[j] / 8;
        M = 1024*10000*6 / Ntile;
        if (Ntile > 32768) M = M / 5;
        if (M == 0) M = 1;
        std::vector<double> r(Ntile), x(Ntile);
        for(i=0; i<x.size(); i++) {
            x[i] = (double)rand() / RAND_MAX;
            x[i] = x[i]*(xmax-xmin)+xmin;
        }

        // https://software.intel.com/content/www/us/en/develop/documentation/onemkl-developer-reference-c/top/vector-mathematical-functions/vm-mathematical-functions/trigonometric-functions/v-sin.html
        auto t1 = std::chrono::high_resolution_clock::now();
        for (k=0; k<M; k++) {
            vmdSin(Ntile,&x[0],&r[0],VML_LA | VML_FTZDAZ_OFF);
            //for(i=0; i<x.size(); i++) {
            //    r[i] = sin(x[i]);
            //}
        }
        auto t2 = std::chrono::high_resolution_clock::now();
        double time_kernel = std::chrono::duration_cast<std::chrono::microseconds>
                (t2 - t1).count();
        time_kernel = time_kernel / M / 1e6;
        std::cout << Ntile << " " << M << " " << time_kernel << std::endl;

    }
    return 0;
}
