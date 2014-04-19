/*
Fields do not participate in polymorphism. (neither static nor instance)
  B < A, four hiding scenarios:
  static - static, static - instance, instance - static, instance - instance.
  Call all four through (A)B ref. Fields from A should be called.
*/

public class static_f_107_no_overwriting {
  public static void main(String[] args) {
    A.a = 1;
    A.c = 3;
    B.a = 5;
    B.b = 6;
    A ab = new B();
    System.out.println(ab.a + " " + ab.b + " " + ab.c + " " + ab.d);
    System.out.println("Done!");
  }
}

class A {
  static int a;
  int b = 2;
  static int c;
  int d = 4;
}

class B extends A {
  static int a,b;
  int c = 7, d = 8;
}
