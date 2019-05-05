int get_one();
int get_two();

int some_test() {
    int a = 0;
    a += 10;
    a += get_one();
    a -= get_two();
    return 0;
}

int get_one() {
    return 1;
}

int get_two() {
    return 2;
}

