class Example4_1_7 {
  static void m(double d) { }
  static void m(long l) { }
  static void test(int i) {
   m(i); // Method m(long) is chosen during compile-time.
  }

  public static void main(String args[]) {
   test(0);
  }
}
