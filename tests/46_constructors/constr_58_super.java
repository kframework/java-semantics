/*
Derived class constructor calls base class constructor through super().
*/

class A {
  A(int a) {
    System.out.println("A(" + a + ")");
  }
}

class B extends A {
  B(int a) {
    super(a);
    System.out.println("B(" + a + ")");
  }
}

public class constr_58_super {
  public static void main(String[] args) {
    new B(1);
    System.out.println("Done!");
  }
}
