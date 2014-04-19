/*
Class initialization conditions.
Class A with both static and instance init tracing.
Static and instance members/inits interleaved. Instantiate A.
*/

public class static_i_trig_107_both_init {
  public static void main(String[] args) {
    new A();
    System.out.println("Done!");
  }
}

class A {

  {
    System.out.println("A.(inst init)");
  }

  static {
    System.out.println("A.(static init)");
  }

  int a = trace(1);

  static int b = trace(2);

  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }

  A() {
    System.out.println("A.A()");
  }
}
