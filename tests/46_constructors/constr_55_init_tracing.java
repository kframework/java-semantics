/*
Two classes with initializer, field with initializer and constructor.
Trace execution within initializer, fields init, constructor
and super call expression. Fields and constructor arguments all have different names.
*/

class A {

  int a = new Tracer().f(1);

  {
    System.out.println("A.init");
  }

  int b = new Tracer().f(2);

  A(int c) {
    System.out.println("A.A("+c+")");
  }
}

class B extends A {
  {
    System.out.println("B.init 1");
  }

  int d = new Tracer().f(3);

  {
    System.out.println("B.init 2");
  }

  B() {
    super(new Tracer().f(4));
    System.out.println("B.B()");
  }
}

class Tracer {
  int f(int a) {
    System.out.println("Tracer.f(" + a + ")");
    return a;
  }
}

public class constr_55_init_tracing {
  public static void main(String[] args) {
    B b = new B();
    System.out.println("Done!");
  }
}
