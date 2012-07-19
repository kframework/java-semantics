// cast from base class to derived, exact type

class A {
}

class B extends A {
  void f() {
    System.out.println("B.f()");
  }
}

public class ref_op_12_cast_base_derived_1 {
  public static void main(String[] args) {
    A a = new B();
    B b = (B) a;
    b.f();

    System.out.println("Done!");
  }
}
