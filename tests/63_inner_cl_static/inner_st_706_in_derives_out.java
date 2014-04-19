/*
Inner class derived from its outer class.
  Class A, A.Inner < A. Members:
  - A.x,
  - A.f() reads x
  - A.g() reads x
  - Inner.x
  - Inner.f() reads x.
  Print Inner.f(), Inner.g(), (A)Inner.f()
*/

public class inner_st_706_in_derives_out {

  public static void main(String[] args) {
    A.Inner inner = new A.Inner();
    System.out.println(inner.f());
    System.out.println(inner.g());
    System.out.println(((A)inner).f());

    System.out.println("Done!");
  }
}

class A {

  String x = "A.x";

  String f() {
    return "A.f(): x = " + x;
  }

  String g() {
    return "A.g(): x = " + x;
  }

  public static class Inner extends A {

    String x = "Inner.x";

    String f() {
      return "Inner.f(): x = " + x;
    }
  }
}

