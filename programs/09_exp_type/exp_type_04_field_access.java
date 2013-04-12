/*
Field access expression
B < A
C{ B x; A y;}
C.x : C.y
*/

public class exp_type_04_field_access {
  public static void main(String[] args) {
    System.out.println("f(true  ? C.x : C.y): " + f(true  ? C.x : C.y));
    System.out.println("f(false ? C.x : C.y): " + f(false ? C.x : C.y));
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

class C {
  static B x = new B();
  static A y = new A();
}
