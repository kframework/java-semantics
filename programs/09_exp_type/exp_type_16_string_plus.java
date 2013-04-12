/*
String additive
B < A
(Object)A : "abc " + A
*/

public class exp_type_16_string_plus {
  public static void main(String[] args) {
    Object o2 = new A();
    System.out.println("f(true  ? o2 : \"abc \" + o2): " + f(true  ? o2 : "abc " + o2));
    System.out.println("f(false ? o2 : \"abc \" + o2): " + f(false ? o2 : "abc " + o2));
    System.out.println("Done!");
  }

  static String f(Object b) {
    return "f(Object): " + b;
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
