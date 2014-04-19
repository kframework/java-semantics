/*
Local var hiding a static field. Class with a static field, method with a local var
  with the same name. Access both from within and outside var scope. Also use this.field.
*/

class A {
  static int a = 2;

  void f() {
    {
      int a = 7;
      System.out.println("f().a = " + a);
      System.out.println("this.a = " + this.a);
    }
    System.out.println("A.a = " + a);
  }
}

public class static_f_109_shadowed_by_local_var {
  public static void main(String[] args) {
    new A().f();
    System.out.println("Done!");
  }
}
