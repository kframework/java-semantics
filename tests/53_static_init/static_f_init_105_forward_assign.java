/*
Field with initializer, initializer have an assignment to other field declared forward.
According to JLS, forward references to fields are permitted inside a filed initializer,
if they are left-hand side of an assignment. We will add an initializer to the assigned field,
and will test it after assign and after initializer.
*/

class A {
  static int a = b = 6;
  static int b1 = A.b;

  static int b = 30;
  static int b2 = b;
}

public class static_f_init_105_forward_assign {
  public static void main(String[] args) {
    System.out.println("" + A.b1 + " " + A.b2);
    System.out.println("Done!");
  }
}
