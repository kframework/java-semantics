abstract class I {
  abstract void m(J x);
}

abstract class J extends I {
  abstract void m(I x);
}

abstract class A extends J {
  void test(J x) {
    this.m(x);   // Reference to m is ambiguous.
    ((A)x).m(x); // Reference to m is ambiguous.
    x.m(x);      // Reference to m is ambiguous.
  }
}
