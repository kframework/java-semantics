/*
A < (I1, I2), one method is common across I1, I2, others are different.
*/

public class interface_32_multi_i_common_method {
  public static void main(String[] args) {
    I1 i1 = new A();
    i1.f();
    i1.g();

    I2 i2 = (I2)i1;
    i2.f();
    i2.h();

    System.out.println("Done!");
  }
}

interface I1 {
  void f();
  void g();
}

interface I2 {
  void f();
  void h();
}

class A implements I1, I2 {
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

