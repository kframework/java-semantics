/*
Inner class members.
  Inner class A.B have members of all access modes:
  - private a
  - package b
  - protected c
  - public d
  - private f()
  - package g()
  - protected h()
  - public k()
  Instantiate A.B from A and access all the members.
*/

public class inner_st_103_members {

  public static void main(String[] args) {
    System.out.println(new A());
    System.out.println("Done!");
  }
}

class A {

  public String toString() {
    A.B b = new A.B();
    return "A: " + b.a + " " + b.b + " " + b.c + " " + b.d + " "
        + b.f() + " " + b.g() + " " + b.h() + " " + b.k();
  }

  public static class B {

    private String a = "a";
    String b = "b";
    protected String c = "c";
    public String d = "d";

    private String f() {return "f()";}
    String g() {return "g()";}
    protected String h() {return "h()";}
    public String k() {return "k()";}

  }
}
