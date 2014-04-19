/*
Inner interface.
  Class A, interface A.II1, class A.Inner < A.II1.
  A.Inner implements an interface method and refers to a static field from II1.
  Tested from main.
*/

public class inner_st_801_inner_interf {

  public static void main(String[] args) {
    System.out.println(((A.II1)new A.Inner()).f());

    System.out.println("Done!");
  }
}

class A {

  static interface II1 {
    String id = "A.II1";

    String f();
  }

  static class Inner implements II1 {

    public String f() {
      return "A.Inner.f(), id = " + id;
    }
  }
}

