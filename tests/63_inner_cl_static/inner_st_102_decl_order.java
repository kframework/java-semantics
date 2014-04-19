/*
Access inner class from outer one. Class A.
  A have the following members, declared in order:
  - class B {toString()}
  - toString() - calls inner classes toString()
  - class C {toString()}
*/

public class inner_st_102_decl_order {

  public static void main(String[] args) {
    System.out.println(new A());
    System.out.println("Done!");
  }
}

class A {

  public static class B {
    public String toString() {
      return "A.B";
    }
  }

  public String toString() {
    return "A: " + new B() + ", " + new C();
  }

  public static class C {
    public String toString() {
      return "A.C";
    }
  }
}
