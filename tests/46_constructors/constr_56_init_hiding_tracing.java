/*
Two classes with initializer, field with initializer and constructor.
  Trace execution within initializer, fields init, constructor.
  and super call expression. Fields and constructor arguments have the same name.
  Fields in derived class hide fields in the base class.
*/

class A {

  int a = new Tracer().f(1);

  {
    System.out.println("A.init");
  }

  int b = new Tracer().f(2);

  A(int a) {
    System.out.println("A.A("+a+")");
    System.out.println("A.A: this.a = "+this.a);
    System.out.println("A.A: this.b = "+this.b);
  }
}

class B extends A {
  {
    System.out.println("B.init 1");
  }

  int a = new Tracer().f(3);

  {
    System.out.println("B.init 2");
  }

  B(int a) {
    super(new Tracer().f(4));
    System.out.println("B.B("+a+")");
    System.out.println("B.B: this.a = "+this.a);
    System.out.println("B.B: this.b = "+this.b);
    System.out.println("B.B: super.a = "+super.a);
  }
}

class Tracer {
  int f(int a) {
    System.out.println("Tracer.f(" + a + ")");
    return a;
  }
}

public class constr_56_init_hiding_tracing {
  public static void main(String[] args) {
    B b = new B(new Tracer().f(5));
    System.out.println("Done!");
  }
}
