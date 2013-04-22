interface I {
  void m(J x);
}

interface J extends I {
  void m(I x);
}

abstract class A implements J {
  void test(J x) {
    this.m(x);
    ((A)x).m(x);
    x.m(x);
  }
}
