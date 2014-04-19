/*
Multifield with init. two groups of three fields each:
  int a, b=..., c;
  int d=..., e, f=...;
  Test their values.
*/

class A {
  static int a, b=1, c;
  static long d=100, e, f=101;
}

public class static_f_init_108_multifield {
  public static void main(String[] args) {
    System.out.println("" + A.a + " " + A.b + " " + A.c + " " + A.d + " " + A.e + " " + A.f);
    System.out.println("Done!");
  }
}
