/*
Fields with initializer, some initializer exps refer to fields declared above.
*/

class A {
  static int a = 3;
  static int b = a + 10;
  static int c = A.a + 100;
}

public class static_f_init_102_backward_ref {
  public static void main(String[] args) {
    System.out.println("" + A.a + " " + A.b + " " + A.c);
    System.out.println("Done!");
  }
}
