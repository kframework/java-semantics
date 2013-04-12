/*
String additive
B < A
(Object)A : "abc " + A
*/

public class exp_type_16_string_plus {
  public static void main(String[] args) {
    Object o2 = new A();
    System.out.println("f(true  ? get(o2) : \"abc \" + get(o2)): " + f(true  ? get(o2) : "abc " + get(o2)));
    System.out.println("f(false ? get(o2) : \"abc \" + get(o2)): " + f(false ? get(o2) : "abc " + get(o2)));
    System.out.println("Done!");
  }

  static String f(Object b) {
    return "f(Object): " + b;
  }

  static String f(A a) {
    return "f(A): " + a;
  }

  static Object get(Object o) {
    System.out.println("get(" + o + ")");
    return o;
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
