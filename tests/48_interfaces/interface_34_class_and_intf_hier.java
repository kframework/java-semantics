/*
A < IA, B < (A, IB) One method is common across interfaces.
  Call through interfaces.
*/

public class interface_34_class_and_intf_hier {
  public static void main(String[] args) {
    IA ia = new B();
    ia.f();
    ia.g();

    IB ib = (IB)ia;
    ib.f();
    ib.h();

    System.out.println("Done!");
  }
}

interface IA {
  void f();
  void g();
}

interface IB {
  void f();
  void h();
}

class A implements IA {
  public void f() {
    System.out.println("A.f()");
  }

  public void g() {
    System.out.println("A.g()");
  }
}

class B extends A implements IB {

  public void f() {
    System.out.println("B.f()");
  }

  public void h() {
    System.out.println("B.h()");
  }
}

