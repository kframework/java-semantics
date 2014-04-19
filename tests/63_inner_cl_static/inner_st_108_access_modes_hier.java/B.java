/*
  p1.B.InnerB:
    - private f(byte)
    - package f(short)
    - protected f(int)
    - public f(long)

    - p1.B.Inner2      < p1.B.InnerB
*/

package p1;

public class B {

  public static class InnerB {
    private String f(byte a) {return "f(byte)";}
    String f(short a) {return "f(short)";}
    protected String f(int a) {return "f(int)";}
    public String f(long a) {return "f(long)";}
  }

  public static class Inner2 extends p1.B.InnerB {

    public String test() {
      return "p1.B.Inner2.test():    " + f((byte)0);
    }

  }
}
