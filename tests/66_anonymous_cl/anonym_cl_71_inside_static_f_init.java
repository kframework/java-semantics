/*
Anonymous class implementing an interface as static field initializer. Access other static fields.
*/

public class anonym_cl_71_inside_static_f_init {
  public static void main(String[] args) {
    O.test();
    System.out.println("Done!");
  }
}

interface I1 {
  void test();
}

class O {

  static int v = 1;

  static String f() {
    return "anon.f()";
  }

  static I1 i1 = new I1() {
    public void test() {
      System.out.println("anon: v = "+ v + ", f() = " + f());
    }
  };

  static void test() {
    System.out.println("i1.test():");
    i1.test();
  }
}
