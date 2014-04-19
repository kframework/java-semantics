/*
Classes p1.A, p1.A.B, p1.A.C. p1.A.B members:
    - private f(byte)
    - package f(short)
    - protected f(int)
    - public f(long)
*/

package p1;

public class A {

  public String test() {
    return "p1.A.test():      " + new p1.A.B().f((byte)0);
  }

  public static class B {

    private String f(byte a) {return "f(byte)";}
    String f(short a) {return "f(short)";}
    protected String f(int a) {return "f(int)";}
    public String f(long a) {return "f(long)";}

    public String test() {
      return "p1.A.B.test():    " + f((byte)0);
    }

  }

  public static class C {
    public String test() {
      return "p1.A.C.test():    " + new p1.A.B().f((byte)0);
    }
  }
}
