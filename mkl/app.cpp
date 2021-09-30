#include <iostream>

int main() {
    int n = 16;
    double x[16];
    double y[16];
    int i;
    for(i=0; i<16; i++) {
        x[i] = 3.14;
    }
//    vdSin(n,x,y);
    for(i=0; i<16; i++) {
        std::cout << x[i] << " " << y[i] << std::endl;
    }
    return 0;
}
