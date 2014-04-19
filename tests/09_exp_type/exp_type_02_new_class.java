/*
new class expression:
B < A,
new B() : new A()
*/

public class exp_type_02_new_class {
  public static void main(String[] args) {
    System.out.println("f(true  ? new B() : new A()): " + f(true  ? new B() : new A()));
    System.out.println("f(false ? new B() : new A()): " + f(false ? new B() : new A()));
    System.out.println("Done!");
  }

  static String f(B b) {
    return "f(B): " + b;
  }

  static String f(A a) {
    return "f(A): " + a;
  }
}

class A {
  A() {
    System.out.println("A()");
  }

  public String toString() {
    return "A";
  }
}

class B extends A {

  B() {
    System.out.println("B()");
  }

  public String toString() {
    return "B";
  }
}
