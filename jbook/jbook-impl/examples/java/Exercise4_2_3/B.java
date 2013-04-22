class A {
  static void m(int x) {}
  static void m(char x) {}
}

class B extends A {
  static void m(long x) {
   m(0);
   m('A');
   m(0L);
  }
}
