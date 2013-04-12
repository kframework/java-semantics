/*
Cast reference
B < A
Object o1 = new B();
Object o2 = new A();
(B) o1 : (A) o2
*/

public class exp_type_13_cast_ref {
  public static void main(String[] args) {
    Object o1 = new B();
    Object o2 = new A();
    System.out.println("f(true  ? (B) o1 : (A) o2): " + f(true  ? (B) o1 : (A) o2));
    System.out.println("f(false ? (B) o1 : (A) o2): " + f(false ? (B) o1 : (A) o2));
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
  public String toString() {
    return "A";
  }
}

class B extends A {
  public String toString() {
    return "B";
  }
}
