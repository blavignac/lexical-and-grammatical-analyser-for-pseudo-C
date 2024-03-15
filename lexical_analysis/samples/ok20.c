int f(int a) {
  return a + 2;
}

void main(void) { // Main function
  int a;
  a = 123 + 321 * 4 / 2 - 1;
  if (a == 1) {
    print(a);
  } else {
    print(a - 1);
    int i, j;
    i = 2;
    j = a - 10;
    while (i < j) {
      i = i + 1;
      int v = f(i) + 2;
      print(v + f(i));
    }
  }
}
