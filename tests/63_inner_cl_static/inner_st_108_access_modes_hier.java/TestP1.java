/*
    - p1.TestP1.Inner3 < p1.A
    - p1.TestP1.Inner4 < p1.B.InnerB
*/

package p1;

public class TestP1 {

  public static class Inner3 extends p1.A {
    public String test() {
      return "p1.TestP1.Inner3.test():    " + f((byte)0);
    }
  }

  public static class Inner4 extends p1.B.InnerB {
    public String test() {
      return "p1.TestP1.Inner4.test():    " + f((byte)0);
    }
  }
}
