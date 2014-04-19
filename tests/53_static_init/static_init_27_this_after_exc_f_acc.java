/*
Static initializer throwing an exception. Access "this" after catching ExceptionInInitializerError.
  Static initialization is triggered by a static field access.
  This is required to test a peculiarity of the implementation.
*/

public class static_init_27_this_after_exc_f_acc {
  public static void main(String[] args) {
    new Test().test();
    System.out.println("Done!");
  }
}

class Test {

  String id = "Test.id";

  void test() {
    try {
      System.out.println("Accessing A.c ...");
      System.out.println(A.c);
    } catch (ExceptionInInitializerError ex) {
      System.out.println(ex);
      System.out.println("Accessing this.id after exception:");
      System.out.println(this.id);
    }
  }
}

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

  static void print() {
    System.out.println("A.print(): " + a + " " + b + " " + c);
  }
}
