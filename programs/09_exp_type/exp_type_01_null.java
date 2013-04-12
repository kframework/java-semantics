/*
A
A : null . f(Object), f(A)
*/

public class exp_type_01_null {
  public static void main(String[] args) {
    System.out.println("f(true  ? a : null): " + f(true  ? createA() : null));
    System.out.println("f(false ? a : null): " + f(false ? createA() : null));
    System.out.println("Done!");
  }

  static String f(Object a) {
    return "f(Object) :" + a;
  }

  static String f(A a) {
    return "f(A) :" + a;
  }

  static A createA() {
    System.out.println("createA()");
    return new A();
  }
}

class A {
  public String toString() {
    return "A";
  }
}

