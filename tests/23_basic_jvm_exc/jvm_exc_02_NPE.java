/*
NullPointerException:
  - ((object)null).toString()
  - ((UserClass)null).x
  - ((UserClass)null).f()
*/

class UserClass {
  int x = 2;
  void f() {
    System.out.println("f()");
  }
}

public class jvm_exc_02_NPE {
  public static void main(String[] args) {
    try {
      Object o = null;
      System.out.println(o.toString());
    } catch (RuntimeException e) {
      System.out.println(e);
    }

    UserClass u = null;
    try {
      System.out.println(u.x);
    } catch (RuntimeException e) {
      System.out.println(e);
    }
    try {
      u.f();
      System.out.println("ok");
    } catch (RuntimeException e) {
      System.out.println(e);
    }
    System.out.println("Done!");
  }
}
