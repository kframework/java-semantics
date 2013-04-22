interface I {
   int m(int i);
}

class B {
  private int m(int i) {
    return i*i;
  }
}

abstract class A extends B implements I {
  static void main(String args[]) { }
}
