/*
A class with three constructors. Chain all of them, explicit call to one-arg super() at last.
Instantiate three objects, using each constructor as primary one. Trace calls
both in the constructor arguments and in the constructor body.
Instance initializers with tracing.
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

  B(int a) {
    super(new Tracer().f(a));
    System.out.println("B.B()");
  }

  B(int a, int b) {
    this(new Tracer().f(a+b));
    System.out.println("B.B(int,int)");
  }

  B(int a, int b, int c) {
    this(new Tracer().f(a + b),c);
    System.out.println("B.B(int,int,int)");
  }
}

class Tracer {
  int f(int a) {
    System.out.println("Tracer.f()");
    return a + 1;
  }
}

public class constr_62_this_chain_w_i_init {
  public static void main(String[] args) {
    B b1 = new B(1,10,100);
    System.out.println();
    B b2 = new B(2,20);
    System.out.println();
    B b3 = new B(3);
    System.out.println();
    System.out.println("Done!");
  }
}
