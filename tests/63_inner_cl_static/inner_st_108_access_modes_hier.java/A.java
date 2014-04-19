/*
  p1.A:
    - private f(byte)
    - package f(short)
    - protected f(int)
    - public f(long)

    - p1.A.Inner1      < p1.A
*/

package p1;

public class A {

  private String f(byte a) {return "f(byte)";}
  String f(short a) {return "f(short)";}
  protected String f(int a) {return "f(int)";}
  public String f(long a) {return "f(long)";}


  public static class Inner1 extends p1.A {

    public String test() {
      return "p1.A.Inner1.test():    " + f((byte)0);
    }

  }
}
