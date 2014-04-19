/*
Param hiding a field. Class with a field, method with a param with the same name.
Access both from within and outside method. Also use this.field.
*/

class A {
  int a = 2;

  void f(int a) {
    {
      System.out.println("f().a = " + a);
      System.out.println("this.a = " + this.a);
    }
    System.out.println("A.a = " + a);
  }
}

public class fields_15_hiding_by_param {
  public static void main(String[] args) {
    new A().f(9);
    System.out.println("Done!");
  }
}
