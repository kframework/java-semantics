/*
Inner interface refers to a field and a method from the outer class by simple name,
  during field init.
  Class A, interface A.IInner.
  members:
    - static A.trace()
    - static A.id calls trace
    - static A.f() calls trace
    - A.IInner.x calls id by simple name
    - A.IInner.y calls f() by simple name
  Main prints A.IInner.x and A.IInner.y
*/

public class inner_st_809_inner_intf_outer_m_call {

  public static void main(String[] args) {
    System.out.println(A.IInner.x);
    System.out.println(A.IInner.y);

    System.out.println("Done!");
  }
}

class A {

  static String trace(String s) {
    System.out.println("trace: " + s);
    return s;
  }

  static String id = trace("A.id");

  static String f() {
    return trace("A.f()");
  }

  static interface IInner {
    String x = "IInner.x: " + id;
    String y = "IInner.y: " + f();
  }
}
