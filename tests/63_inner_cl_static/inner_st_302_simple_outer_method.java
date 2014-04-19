/*
Static method access from inner class to outer class by simple name.
  B, B.Inner.
  Members:
    - static B.f()
  Call them as B.f(), f() from B.Inner from static and instance context.
*/

public class inner_st_302_simple_outer_method {

  public static void main(String[] args) {
    new B.Inner().test();
    B.Inner.staticTest();
    System.out.println("Done!");
  }
}

class B {

  static String f() {
    return "B.f()";
  }

  public static class Inner {
    public void test() {
      System.out.println("B.Inner:");
      System.out.println(B.f());
      System.out.println(f());
    }

    public static void staticTest() {
      System.out.println("B.Inner:");
      System.out.println(B.f());
      System.out.println(f());
    }
  }
}
