/*
ClassCastException.
  Hierarchy: Object -> A B; B -> C; C -> D
  - Object a = A; (D)a;
  - B c = C; (D)c;
*/

class A{}
class B{}
class C extends B{}
class D extends C{}

public class jvm_exc_03_cast_exc_hierarchy {
  public static void main(String[] args) {
    try {
      Object a = new A();
      D d = (D)a;
      System.out.println(d);
    } catch (RuntimeException e) {
      System.out.println(e);
    }
    try {
      B c = new C();
      D d = (D)c;
      System.out.println(d);
    } catch (RuntimeException e) {
      System.out.println(e);
    }

    System.out.println("Done!");
  }
}
