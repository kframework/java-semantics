/*
Name collisions between constructor/method/field.
  Class A have:
  - a constructor A()
  - a method int A()
  - a field int A.
  Test that all three may be unambiguously referred from both inside and outside the class.
*/

public class constr_91_name_collision {

  public static void main(String[] args) {
    System.out.println("Inside A:");
    new A(0);
    System.out.println("Outside A:");
    A a = new A();
    a.A();
    a.A = 2;
    System.out.println("A field = "+a.A);

    System.out.println("Done!");
  }
}

class A {

  A(int x) {
    this();
    A();
    A = 1;
    System.out.println("A field = "+A);
  }

  A() {
    System.out.println("A.A() constructor");
  }

  void A() {
    System.out.println("A.A() method");
  }

  int A;
}
