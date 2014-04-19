// cast from base class to derived, instance is more derived type.

class A {
}

class B extends A {
  void f() {
    System.out.println("B.f()");
  }
}

class C extends B {
  void f() {
    System.out.println("C.f()");
  }
}

public class ref_op_13_cast_base_derived_2 {
  public static void main(String[] args) {
    A a = new C();
    B b = (B) a;
    b.f();

    System.out.println("Done!");
  }
}
