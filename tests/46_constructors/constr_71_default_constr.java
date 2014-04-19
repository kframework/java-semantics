/*
Class A with an instance initializer with a trace. No constructor.
Call it explicitly, from subclass implicitly, from subclass explicitly.
*/

class A {
  {
    System.out.println("A.init");
  }
}

class B extends A {
  {
    System.out.println("B.init");
  }

  B() {
    System.out.println("B.B()");
  }

  B(int a) {
    super();
    System.out.println("B.B(int)");
  }
}

public class constr_71_default_constr {
  public static void main(String[] args) {
    new A();
    new B();
    new B(1);
    System.out.println("Done!");
  }
}
