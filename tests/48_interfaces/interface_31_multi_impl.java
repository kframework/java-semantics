/*
A < (I1, I2). Call all interface methods through I1, I2.
*/

public class interface_31_multi_impl {
  public static void main(String[] args) {
    I1 i1 = new A();
    i1.f();

    I2 i2 = (I2)i1;
    i2.g();

    System.out.println("Done!");
  }
}

interface I1 {
  void f();
}

interface I2 {
  void g();
}

class A implements I1, I2 {
  public void f() {
    System.out.println("A.f()");
  }

  public void g() {
    System.out.println("A.g()");
  }
}

