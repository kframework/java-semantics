class A {
  static void m(int x, long y) {}
  static void m(long x, int y) {
    m(0,0); // Reference to m is ambiguous.
  }
}
