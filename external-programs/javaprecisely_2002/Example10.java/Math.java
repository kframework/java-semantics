class Math {
  static int seed = 1;

  static double random() {
    return ((seed++) * 83) % 101.0 / 101.0;
  }

  static double PI = 3.14;

  static double min(double a, double b) {
    return a < b ? a : b;
  }
}
