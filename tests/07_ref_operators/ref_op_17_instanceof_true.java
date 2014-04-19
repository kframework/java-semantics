// instanceof true: base class is exact derived class
// instanceof true: base class is derived class, instance is more derived class.

class A {}
class B extends A {}
class C extends B {}

public class ref_op_17_instanceof_true {
  public static void main(String[] args) {
    A b = new B();
    A c = new C();

    System.out.println(b instanceof B);
    System.out.println(c instanceof B);

    System.out.println("Done!");
  }
}
