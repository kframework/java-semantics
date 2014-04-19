/*
Class/interface init do not trigger superinterface init.
A < I1. Class A instantiation. I1 init is not triggered.
Access a field in I1 - I1 init is triggered.
*/

public class static_i_trig_203_c_i_no_init {
  public static void main(String[] args) {
    new A();
    System.out.println("I1.a=" + I1.a);
    System.out.println("Done!");
  }
}

interface I1 {
  int a = T.trace(1);
}

class A implements I1 {

  static int b = T.trace(2);

  A() {
    System.out.println("A.A()");
  }
}

class T {
  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }
}
