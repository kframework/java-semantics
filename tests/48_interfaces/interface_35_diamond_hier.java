/*
Diamond hierarchy.
  A < I4. I4 < (I2, I3). (I2, I3) < I1.
  Each interface have a specific method. Some methods are redeclared.
*/

public class interface_35_diamond_hier {
  public static void main(String[] args) {
    System.out.println("Target var I1:");
    I1 i1 = new A();
    i1.f();
    i1.g();
    i1.h1();

    System.out.println("\nTarget var I2:");
    I2 i2 = (I2)i1;
    i2.f();
    i2.g();
    i2.h1();
    i2.h2();

    System.out.println("\nTarget var I3:");
    I3 i3 = (I3)i2;
    i3.f();
    i3.g();
    i3.h1();
    i3.h3();

    System.out.println("\nTarget var I4:");
    I4 i4 = (I4)i3;
    i4.f();
    i4.g();
    i4.h1();
    i4.h2();
    i4.h3();
    i4.h4();

    System.out.println("Done!");
  }
}

interface I1 {
  void f();
  void g();
  void h1();
}

interface I2 extends I1 {
  void f();
  void g();
  void h2();
}

interface I3 extends I1 {
  void f();
  void h3();
}

interface I4 extends I2, I3 {
  void f();
  void h4();
}

class A implements I4 {
  public void f() {
    System.out.println("A.f()");
  }

  public void g() {
    System.out.println("A.g()");
  }

  public void h1() {
    System.out.println("A.h1()");
  }

  public void h2() {
    System.out.println("A.h2()");
  }

  public void h3() {
    System.out.println("A.h3()");
  }

  public void h4() {
    System.out.println("A.h4()");
  }
}


