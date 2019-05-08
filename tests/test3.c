int get_one();
int get_two();

int some_test() {
    return get_one() + get_two();
}

int get_one() {
    return 1;
}

int get_two() {
    return 2;
}

