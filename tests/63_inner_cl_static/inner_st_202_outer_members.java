/*
Inner class calls outer class members of all modes.
  A, A.B.
  A members:
    - private a
    - package b
    - protected c
    - public d
    - private f()
    - package g()
    - protected h()
    - public k()
  Call all from A.B.
*/

public class inner_st_202_outer_members {

  public static void main(String[] args) {
    System.out.println(new A.B());
    System.out.println("Done!");
  }
}

class A {

  private String a = "a";
  String b = "b";
  protected String c = "c";
  public String d = "d";

  private String f() {return "f()";}
  String g() {return "g()";}
  protected String h() {return "h()";}
  public String k() {return "k()";}

  public static class B {

    public String toString() {
      A a = new A();
      return "A.B: " + a.a + " " + a.b + " " + a.c + " " + a.d + " "
          + a.f() + " " + a.g() + " " + a.h() + " " + a.k();
    }

  }
}
