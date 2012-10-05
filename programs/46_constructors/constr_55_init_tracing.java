/*
Two classes with initializer and constructor. Trace execution within initializer, constructor
and super call expression.
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
    System.out.println("Tracer.f()");
    return 29;
  }
}

public class constr_55_init_tracing {
  public static void main(String[] args) {
    B b = new B();
    System.out.println("Done!");
  }
}
