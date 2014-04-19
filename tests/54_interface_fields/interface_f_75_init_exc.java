/*
Fields with initializer throwing an exception. Test that all the remaining initializers
  are not executed. Catch StaticInitializationError in main.
*/

interface I1 {
  int a = Auxx.ok();
  int b = Auxx.exc();
  int c = Auxx.afterExc();
}

class Auxx {

  static int ok() {
    System.out.println("Auxx.ok()");
    return 3;
  }

  static int exc() {
    System.out.println("Auxx.exc()");
    throw new RuntimeException("re");
  }

  static int afterExc() {
    System.out.println("Auxx.afterExc()");
    return 4;
  }
}

public class interface_f_75_init_exc {
  public static void main(String[] args) {
    try {
      System.out.println(I1.a);
    } catch (ExceptionInInitializerError ex) {
      System.out.println(ex);
    }
    System.out.println("Done!");
  }
}
