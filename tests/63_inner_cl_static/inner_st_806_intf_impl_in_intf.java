/*
Outer class and outer interface implement an inner interface of another class.
  Class A, interface A.IInner, B < IInner, I2 < IInner.
  Members:
    - IInner.f()
    - IInner.id
    - B.f()
  Call (IInner)B.f(), B.id, I2.id.
*/

public class inner_st_806_intf_impl_in_intf {

  public static void main(String[] args) {
    System.out.println(((A.IInner)new B()).f() + " " + B.id + " " + I2.id);

    System.out.println("Done!");
  }
}

class A {

  static interface IInner {
    String f();

    String id = "A.IInner.id";
  }
}

class B implements A.IInner {
  public String f() {
    return "B.f()";
  }
}

interface I2 extends A.IInner {}
