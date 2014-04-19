/*
Access methods from Object() through an interface. According to JLS $9.2 this is possible.
  A < I1 < I2. Test that both I1 and I2 have access to equals() and toString().
*/

public class interface_41_methods_from_cl_object {
  public static void main(String[] args) {
    A a = new A();
    I1 i1 = a;
    System.out.println("i1.equals(): "+ i1.equals(a) + " " + i1.equals(null));
    System.out.println("i1.toString(): "+ i1.toString());

    I2 i2 = a;
    System.out.println("i2.equals(): "+ i2.equals(i1) + " " + i2.equals(null));
    System.out.println("i2.toString(): "+ i2.toString());

    System.out.println("Done!");
  }
}

interface I1 {
  void f();
}

interface I2 extends I1 {}

class A implements I2 {
  public void f() {
    System.out.println("A.f()");
  }

  public String toString() {
    return "A.toString()";
  }
}

