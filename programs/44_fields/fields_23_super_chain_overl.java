/*
B < A. Call to B: f(super.x.y) where A.x.y and B.x.y are of different types, f() overloaded.
*/

class A {
  AuxA x = new AuxA();
}

class B extends A {
  AuxB x = new AuxB();

  String f(int y) {
    return "B.f(int)";
  }

  String f(boolean y) {
    return "B.f(boolean)";
  }

  void test() {
    System.out.println("f(this.x.y)  = " + f(this.x.y));
    System.out.println("f(super.x.y) = " + f(super.x.y));
  }
}

class AuxA {
  int y;
}

class AuxB {
  boolean y;
}

public class fields_23_super_chain_overl {
  public static void main(String[] args) {
    new B().test();
    System.out.println("Done!");
  }
}
