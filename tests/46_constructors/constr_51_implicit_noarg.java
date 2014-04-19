/*
Two classes, implicit call of no-args superclass constructor.
*/

class A {
  A() {
    System.out.println("A.A()");
  }
}

class B extends A {
  B() {
    System.out.println("B.B()");
  }
}

public class constr_51_implicit_noarg {
  public static void main(String[] args) {
    B b = new B();
    System.out.println("Done!");
  }
}
