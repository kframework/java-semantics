/*
Fileds with initializer, all initialized with a constant expression.
*/

class A {
  static int a = 2;
  static int b = 4 + 5;
  static int c = (int) 9876543210L;
}

public class static_f_init_101_const {
  public static void main(String[] args) {
    System.out.println("" + A.a + " " + A.b + " " + A.c);
    System.out.println("Done!");
  }
}
