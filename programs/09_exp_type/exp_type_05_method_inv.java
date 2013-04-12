/*
B < A
fB() : fA()
B fB(){}
A fA(){}
Methods with side effects
*/

public class exp_type_05_method_inv {
  public static void main(String[] args) {
    System.out.println("f(true  ? fB() : fA()): " + f(true  ? fB() : fA()));
    System.out.println("f(false ? fB() : fA()): " + f(false ? fB() : fA()));
    System.out.println("Done!");
  }

  static A fA() {
    System.out.println("fA()");
    return new A();
  }

  static B fB() {
    System.out.println("fB()");
    return new B();
  }

  static String f(B b) {
    return "f(B): " + b;
  }

  static String f(A a) {
    return "f(A): " + a;
  }
}

class A {
  public String toString() {
    return "A";
  }
}

class B extends A {
  public String toString() {
    return "B";
  }
}
