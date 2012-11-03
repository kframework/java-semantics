/*
Fields with initializer throwing an exception. Test that all the remaining initializers
  are not executed. Catch StaticInitializationError in main.
*/

interface I1 {
  int a = Aux.ok();
  int b = Aux.exc();
  int c = Aux.afterExc();
}

class Aux {

  static int ok() {
    System.out.println("Aux.ok()");
    return 3;
  }

  static int exc() {
    System.out.println("Aux.exc()");
    throw new RuntimeException("re");
  }

  static int afterExc() {
    System.out.println("Aux.afterExc()");
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
