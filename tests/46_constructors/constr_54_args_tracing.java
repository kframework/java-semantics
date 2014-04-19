/*
Two classes, superclass constructor call arguments are expressions using this constructor arguments,
also calling methods that print something to the console.
*/

class A {
  A(int a) {
    System.out.println("A.A("+a+")");
  }
}

class B extends A {
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

public class constr_54_args_tracing {
  public static void main(String[] args) {
    B b = new B();
    System.out.println("Done!");
  }
}
