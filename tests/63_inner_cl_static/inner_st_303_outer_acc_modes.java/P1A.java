package p1;

public class P1A extends P1B {

  private static String f(byte a) {return "f(byte)";}
  static String f(short a) {return "f(short)";}
  protected static String f(int a) {return "f(int)";}
  public static String f(long a) {return "f(long)";}

  public static class Inner {
    public static void test() {
      System.out.println(f((byte)0));
      System.out.println(g((byte)0));
      System.out.println(h((byte)0));
      System.out.println(P1D.k((byte)0));
    }
  }

}
