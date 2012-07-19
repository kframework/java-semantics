// instanceof false: base class is not derived class
// instanceof false: base class is first derived class, but not second, more derived class.
// instanceof false: base class is one derived class, but not another one, unrelated.

class A {}
class B extends A {}
class C extends B {}
class D extends A {}

public class ref_op_18_instanceof_false {
  public static void main(String[] args) {
    A a = new A();
    A b = new B();

    System.out.println(a instanceof B);
    System.out.println(b instanceof C);
    System.out.println(b instanceof D);

    System.out.println("Done!");
  }
}
