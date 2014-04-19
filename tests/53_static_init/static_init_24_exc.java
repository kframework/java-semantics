/*
Static initializer throwing exc. The remaining field and static initializers are not executed.
*/

class A {

  static int a = 2;

  static {
    print();
  }

  static int b = 3;

  static {
    if (true) {
      throw new RuntimeException("re");
    }
  }

  static int c = 4;

  static void f() {
    System.out.println("A.f()");
  }

  static void print() {
    System.out.println(a + " " + b + " " + c);
  }
}

public class static_init_24_exc {
  public static void main(String[] args) {
    try {
      A.f();
    } catch (ExceptionInInitializerError ex) {
      System.out.println(ex);
      //A.print(); would give NoClassDefFoundError: Could not initialize class A
    }
    System.out.println("Done!");
  }
}
