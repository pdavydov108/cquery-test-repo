#include <iostream>

struct Data {
    int a = 1;
    int b = 2;
};

int main(int argc, char *argv[]) {
    Data data;
    std::cout << data.a << std::endl;
    return 0;
}
