/*
Inner class access modes. Classes p1.A, p1.A.B, p1.A.C, p1.P1Test, p1.P1Test.D,
  DefTest, DefTest.E. p1.A.B members:
    - private f(byte)
    - package f(short)
    - protected f(int)
    - public f(long)
  Call f(byte) from:
    - p1.A
    - p1.A.B
    - p1.A.C
    - p1.P1Test
    - p1.P1Test.D
    - <default>.DefTest
    - DefTest.E
*/

public class inner_st_104_access_modes {

  public static void main(String[] args) {
    System.out.println(new p1.A().test());
    System.out.println(new p1.A.B().test());
    System.out.println(new p1.A.C().test());
    System.out.println(new p1.P1Test().test());
    System.out.println(new p1.P1Test.D().test());
    System.out.println(new DefTest().test());
    System.out.println(new DefTest.E().test());
    System.out.println("Done!");
  }
}

class DefTest {

  public String test() {
    return "DefTest.test():   " + new p1.A.B().f((byte)0);
  }

  public static class E {
    public String test() {
      return "DefTest.E.test(): " + new p1.A.B().f((byte)0);
    }
  }
}
