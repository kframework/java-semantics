/*
  - private A.f(byte)
  - package A.f(short)
  - protected A.f(int)
  - public A.f(long)
*/

package p1;

public class A {
  private String f(byte a) {
    return "private p1.A.f(byte)";
  }

  String f(short a) {
    return "package p1.A.f(short)";
  }

  protected String f(int a) {
    return "protected p1.A.f(int)";
  }

  public String f(long a) {
    return "public p1.A.f(long)";
  }
}
