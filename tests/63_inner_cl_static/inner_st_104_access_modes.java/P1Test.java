package p1;

public class P1Test {

  public String test() {
    return "p1.P1Test.test(): " + new p1.A.B().f((byte)0);
  }

  public static class D {
    public String test() {
      return "p1.P1Test.D.test(): " + new p1.A.B().f((byte)0);
    }
  }
}
