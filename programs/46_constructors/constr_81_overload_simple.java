/*
Standart constructor overloading.
  decl: A: A(), A(short), A(long).
  calls: arguments: (), (short), (int)
*/

public class constr_81_overload_simple {

  public static void main(String[] args) {
    new A();
    new A((short)0);
    new A((int)0);

    System.out.println("Done!");
  }
}

class A {
  A() {
    System.out.println("A.A()");
  }

  A(short a) {
    System.out.println("A.A(short)");
  }

  A(long a) {
    System.out.println("A.A(long)");
  }
}
