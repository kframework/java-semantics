interface I {
   int m(int i);
}

class B {
  private int m(int i) {
    return i*i;
  }
}

abstract class Example4_1_5 extends B implements I {
  public static void main(String args[]) { }
}
