/*
Argument to super() throws an exception. Test that instance initializers
are not executed on neither base nor derived class. Do this by printing
something in the instance initializers.
*/

class A {
  {
    System.out.println("A.init");
  }
  A(int a) {
    System.out.println("A.A("+a+")");
  }
}

class B extends A {
  {
    System.out.println("B.init");
  }

  B() {
    super(new Tracer().f());
    System.out.println("B.B()");
  }
}

class Tracer {
  int f() {
    System.out.println("Tracer.f(). Throwing exception...");
    throw new RuntimeException("re");
  }
}

public class constr_57_init_exc {
  public static void main(String[] args) {
    try {
      B b = new B();
    } catch (RuntimeException re) {
      System.out.println(re);
    }
    System.out.println("Done!");
  }
}
