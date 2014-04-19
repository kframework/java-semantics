/*
Conditional ternary operator ?:
B < A
boolean fTrue() {} boolean fFalse() {} - with side effects
fTrue() ? A : A : fFalse() ? B : B
*/

public class exp_type_26_cond_op {
  public static void main(String[] args) {
     B b = new B(); A a = new A();

    System.out.println("f(true  ? fTrue() ? a : a : fFalse() ? b : b): " + f(true  ? fTrue() ? a : a : fFalse() ? b : b));
    System.out.println("f(false ? fTrue() ? a : a : fFalse() ? b : b): " + f(false ? fTrue() ? a : a : fFalse() ? b : b));

    System.out.println("Done!");
  }

  static String f(B b) {
    return "f(B): " + b;
  }

  static String f(A a) {
    return "f(A): " + a;
  }

  static boolean fTrue() {
    System.out.println("fTrue()");
    return true;
  }

  static boolean fFalse() {
    System.out.println("fFalse()");
    return false;
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
