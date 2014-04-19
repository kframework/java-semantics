/*
Class/interface init do not trigger superinterface init.
A < I1{f()}. Instantiate A and call the method f. I1 init is not triggered.
*/

public class static_i_trig_205_intf_m_call_no_init {
  public static void main(String[] args) {
    ((I1) new A()).f();
    System.out.println("I1.a=" + I1.a);
    System.out.println("Done!");
  }
}

interface I1 {
  int a = T.trace(1);

  void f();
}

class A implements I1 {

  static int b = T.trace(2);

  A() {
    System.out.println("A.A()");
  }

  public void f() {
    System.out.println("A.f()");
  }
}

class T {
  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }
}
