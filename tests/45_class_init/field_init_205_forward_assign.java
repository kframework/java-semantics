/*
Field with initializer, initializer have an assignment to other field declared forward.
According to JLS, forward references to fields are permitted inside a filed initializer,
if they are left-hand side of an assignment. We will add an initializer to the assigned field,
and will test it after assign and after initializer.
*/

class A {
  int a = b = 6;
  int b1 = this.b;

  int b = 30;
  int b2 = b;
}

public class field_init_205_forward_assign {
  public static void main(String[] args) {
    A a = new A();
    System.out.println("" + a.b1 + " " + a.b2);
    System.out.println("Done!");
  }
}
