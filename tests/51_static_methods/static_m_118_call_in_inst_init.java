/*
Unqualified static method in instance initializing contexts.
  Access a static method through unqualified expression in:
  - instance field initializer
  - instance initializer
  - super() call
  - constructor
*/

public class static_m_118_call_in_inst_init {
  public static void main(String[] args) {
    new B();
    System.out.println("Done!");
  }
}

class A {
  A(int a) {
    System.out.println("A.A("+a+")");
  }

  static int s_g(int a) {
    System.out.println("B.s_g("+a+")");
    return a;
  }
}

class B extends A {
  int v = s_g(1);

  {
    System.out.println("inst init: "+s_g(2));
  }

  B() {
    super(s_g(3));
    System.out.println("constructor: "+s_g(4));
  }
}

