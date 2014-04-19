/*
Fields with initializer throwing an exception. Test that all the remaining initializers
  and the constructor are not executed. Catch ExceptionInInitializerError in main.
*/

class A {
  static int a = ok();
  static int b = exc();
  static int c = afterExc();

  static int ok() {
    System.out.println("A.ok()");
    return 3;
  }

  static int exc() {
    System.out.println("A.exc()");
    throw new RuntimeException("re");
  }

  static int afterExc() {
    System.out.println("A.afterExc()");
    return 4;
  }
}

public class static_f_init_107_exc {
  public static void main(String[] args) {
    try {
      System.out.println(A.a);
    } catch (ExceptionInInitializerError ex) {
      System.out.println(ex);
    }
    System.out.println("Done!");
  }
}
