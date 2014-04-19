/*
Inner class as derived class.
  classes A, B, A.Inner < B.
  B members:
    - String a
    - String f()
    - String g()
  A.Inner members:
    - String a
    - String f()

  print a, f(), g() on targets (A.Inner)A.Inner and (B)A.Inner.
*/

public class inner_st_105_inner_hier {

  public static void main(String[] args) {
    A.Inner inner = new A.Inner();
    System.out.println("(A.Inner): " + inner.a + " " + inner.f() + " " + inner.g());
    B b = inner;
    System.out.println("(B)      : " + b.a + " " + b.f() + " " + b.g());
    System.out.println("Done!");
  }
}

class A {

  public static class Inner extends B {

    String a = "A.Inner.a";

    String f() {return "A.Inner.f()";}

  }
}

class B {
  String a = "B.a";

  String f() {return "B.f()";}

  String g() {return "B.g()";}
}
