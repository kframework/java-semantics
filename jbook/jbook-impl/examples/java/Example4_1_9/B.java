class A {
  static void m(int x) {}
}

class B extends A {
  static void m(long x) {
    m(0); // Reference to m is ambiguous.
  }
}
