/*
Inner class implements interface.
  class A, interface I1, class A.C
  I1:
    - String a;
    - String f();
  A.C:
    - String f()
  Print ((I1)A.C).a, ((I1)A.C).f().
*/

public class inner_st_106_inner_impl_intf {

  public static void main(String[] args) {
    I1 i1 = new A.Inner();
    System.out.println("(I1): " + i1.a + " " + i1.f());
    System.out.println("Done!");
  }
}

class A {

  public static class Inner implements I1 {

    public String f() {return "A.Inner.f()";}

  }
}

interface I1 {
  String a = "I1.a";

  String f();

}
