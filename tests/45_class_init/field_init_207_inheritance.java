/*
Fields with initializer, referring to superclass fields/methods.
*/

class A {
  int a = 5;

  int f() {
    System.out.println("f()");
    return 3;
  }
}

class B extends A {

  int b = a + 10;
  int c = f() + 10;
}

public class field_init_207_inheritance {
  public static void main(String[] args) {
    B b = new B();
    System.out.println("" + b.a + " " + b.b + " " + b.c);
    System.out.println("Done!");
  }
}
