/*
Static initializer throwing an exception. Access "this" after catching ExceptionInInitializerError.
  Static initialization is triggered by a method call.
  This is required to test a peculiarity of the implementation.
*/

public class static_init_26_this_after_exc_m_call {
  public static void main(String[] args) {
    new Test().test();
    System.out.println("Done!");
  }
}

class Test {

  String id = "Test.id";

  void test() {
    try {
      A.f();
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

  static void f() {
    System.out.println("A.f()");
  }

  static void print() {
    System.out.println("A.print(): " + a + " " + b + " " + c);
  }
}
