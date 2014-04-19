/*
Fields with initializer, initializer exps refer to fields declared below. Default values exposed.
*/

class A {
  static int a = A.b;
  static int b = a + 10;
  static int c = b;
}

public class static_f_init_103_forward_ref {
  public static void main(String[] args) {
    System.out.println("" + A.a + " " + A.b + " " + A.c);
    System.out.println("Done!");
  }
}
