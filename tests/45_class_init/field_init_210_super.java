/*
Using super in the field initializer. Call a super field/method with the same name
as a member in this class, from a filed initializer.
*/

class A {

  int a = 8;

  int f() {
    System.out.println("A.f()");
    return 3;
  }

}

class B extends A {
  int a = super.a + 10;
  int b = f();
  int c = super.f();

  int f() {
    System.out.println("B.f()");
    return 33;
  }
}

public class field_init_210_super {
  public static void main(String[] args) {
    B b = new B();
    System.out.println("" + b.a + " " + b.b + " " + b.c);
    System.out.println("Done!");
  }
}
