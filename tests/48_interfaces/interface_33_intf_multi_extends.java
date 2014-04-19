/*
A < I1 < (I2, I3). Call through all interfaces.
*/

public class interface_33_intf_multi_extends {
  public static void main(String[] args) {
    I1 i1 = new A();
    i1.f();

    I2 i2 = (I2)i1;
    i2.g();

    I3 i3 = (I3)i2;
    i3.f();
    i3.g();
    i3.h();

    System.out.println("Done!");
  }
}

interface I1 {
  void f();
}

interface I2 {
  void g();
}

interface I3 extends I1, I2 {
  void h();
}

class A implements I3 {
  public void f() {
    System.out.println("A.f()");
  }

  public void g() {
    System.out.println("A.g()");
  }

  public void h() {
    System.out.println("A.h()");
  }
}

