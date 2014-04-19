/*
Fields with initializer, initializer exps refer to fields declared below. Default values exposed.
*/

class A {
  int a = this.b;
  int b = a + 10;
  int c = b;
}

public class field_init_203_forward_ref {
  public static void main(String[] args) {
    A a = new A();
    System.out.println("" + a.a + " " + a.b + " " + a.c);
    System.out.println("Done!");
  }
}
