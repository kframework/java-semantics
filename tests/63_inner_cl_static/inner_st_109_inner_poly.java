/*
Inner class derived from a to-pevel class. Call an overwritten method
    through the base class ref.
  Classes A, B, A.Inner < B.
  B members:
    - String f()
  A.Inner members:
    - String f()

  Print f() on target (B)A.Inner.
*/

public class inner_st_109_inner_poly {

  public static void main(String[] args) {
    B b = new A.Inner();
    System.out.println(b.f());
    System.out.println("Done!");
  }
}

class A {
  public static class Inner extends B {
    String f() {return "A.Inner.f()";}
  }
}

class B {
  String f() {return "B.f()";}
}
