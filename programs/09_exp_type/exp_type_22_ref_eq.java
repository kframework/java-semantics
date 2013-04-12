/*
Equality: reference
B < A
B b = new B(); A a = new A();
b == b : a == b
b != b : a != b
*/

public class exp_type_22_ref_eq {
  public static void main(String[] args) {
    B b = new B(); A a = new A();

    System.out.println("f(true  ? b == b : a == b): " + f(true  ? b == b : a == b));
    System.out.println("f(false ? b == b : a == b): " + f(false ? b == b : a == b));
    System.out.println("f(true  ? b != b : a != b): " + f(true  ? b != b : a != b));
    System.out.println("f(false ? b != b : a != b): " + f(false ? b != b : a != b));

    System.out.println("Done!");
  }

  static String f(boolean b) {
    return "f(boolean): " + b;
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
