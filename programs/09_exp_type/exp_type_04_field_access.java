/*
Field access expression
C{ int x; long y;}
C.x : C.y
*/

public class exp_type_04_field_access {
  public static void main(String[] args) {
    System.out.println("f(true  ? C.x : C.y): " + f(true  ? new C(1).x : new C(2).y));
    System.out.println("f(false ? C.x : C.y): " + f(false ? new C(3).x : new C(4).y));
    System.out.println("Done!");
  }

  static String f(int b) {
    return "f(int): " + b;
  }

  static String f(long a) {
    return "f(long): " + a;
  }
}

class C {
  int x;
  long y;

  C(int a) {
    System.out.println("C(" + a + ")");
    x = 10 * a;
    y = 100 * a;
  }
}
