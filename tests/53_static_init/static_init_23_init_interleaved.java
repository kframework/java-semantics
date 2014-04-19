/*
Field, static initializer, field, static initializer.
*/

class A {

  static int a = 2;

  static {
    print();
  }

  static int b = 3;

  static {
    print();
  }

  static int c = 4;

  static void f() {
    print();
  }

  static void print() {
    System.out.println(a + " " + b + " " + c);
  }
}

public class static_init_23_init_interleaved {
  public static void main(String[] args) {
    A.f();
    System.out.println("Done!");
  }
}
