/*
Class A. Multiple constructors with one arg - different int types.
  Call them by:
  - instantiating A
  - instantiating B < A, by super().
  - instantiating A, by this() - constructors should be chained, with explicit cast to most
    specific type.
*/

public class constr_82_overload_multicontext {

  public static void main(String[] args) {
    new B((byte)1);
    new B((short)1);
    new B(1L);

    System.out.println("Done!");
  }
}

class A {
  A(byte a) {
    this((short)a);
    System.out.println("A.A(byte)");
  }

  A(int a) {
    this((long)a);
    System.out.println("A.A(int)");
  }

  A(long a) {
    System.out.println("A.A(long)");
  }
}

class B extends A {
  B(byte a) {
    super(a);
    System.out.println("B.B(byte)");
  }

  B(int a) {
    super((short)a);
    System.out.println("B.B(int)");
  }

  B(long a) {
    super(a);
    System.out.println("B.B(long)");
  }
}
