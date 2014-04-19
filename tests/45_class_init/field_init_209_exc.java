/*
Fields with initializer throwing an exception. Test that all the remaining initializers
  and the constructor are not executed.
*/

class A {
  int a = ok();
  int b = exc();
  int c = afterExc();

  int ok() {
    System.out.println("A.ok()");
    return 3;
  }

  int exc() {
    System.out.println("A.exc()");
    throw new RuntimeException("re");
  }

  int afterExc() {
    System.out.println("A.afterExc()");
    return 4;
  }

  A() {
    System.out.println("A.A");
  }
}

public class field_init_209_exc {
  public static void main(String[] args) {
    try {
      A a = new A();
    } catch (RuntimeException re) {
      System.out.println(re);
    }
    System.out.println("Done!");
  }
}
