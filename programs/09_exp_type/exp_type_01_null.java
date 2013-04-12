/*
A
A : null . f(Object), f(A)
*/

public class exp_type_01_null {
  public static void main(String[] args) {
    A a = new A();
    System.out.println("f(true  ? a : null): " + f(true  ? a : null));
    System.out.println("f(false ? a : null): " + f(false ? a : null));
    System.out.println("Done!");
  }

  static String f(Object a) {
    return "f(Object) :" + a;
  }

  static String f(A a) {
    return "f(A) :" + a;
  }
}

class A {
  public String toString() {
    return "A";
  }
}

