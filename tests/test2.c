int get_one();
int get_two();

int some_test() {
    int a = 0;
    a += 10;
    if (a == 0)    a += get_one();
    if (a <= 10)   a -= get_two();
    if (a > 10)    a = get_one();
    if (a >= 5)    a += get_two();
    if (a < 8)     a -= get_one();
    return 0;
}

int get_one() {
    return 1;
}

int get_two() {
    return 2;
}

