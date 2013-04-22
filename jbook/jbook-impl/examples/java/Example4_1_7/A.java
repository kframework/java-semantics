class A {
  static void m(double d) { }
  static void m(long l) { }
  static void test(int i) {
   m(i); // Method m(long) is chosen during compile-time.
  }

  static void main(String args[]) {
   test(0);
  }
}
