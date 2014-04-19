/*
Class/interface init do not trigger superinterface init.
A < I1{v, getV()} Instantiate A and call getV() that returns v.
    I1 init is triggered.
*/

public class static_i_trig_206_intf_f_call_init {
  public static void main(String[] args) {
    System.out.println("A.getA()=" + new A().getA());
    System.out.println("I1.a=" + I1.a);
    System.out.println("Done!");
  }
}

interface I1 {
  int a = T.trace(1);

  int getA();
}

class A implements I1 {

  static int b = T.trace(2);

  A() {
    System.out.println("A.A()");
  }

  public int getA() {
    System.out.println("A.getA()");
    return a;
  }
}

class T {
  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }
}
