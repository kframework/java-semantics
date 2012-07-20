/*
ArithmeticException:
  - 2 / 0
  - 2 % 0
  - 2L / 0L
*/

public class jvm_exc_01_arith_exc {
  public static void main(String[] args) {
    try {
      int a = 2 / 0;
      System.out.println("ok");
    } catch (RuntimeException e) {
      System.out.println(e);
    }
    try {
      int a = 2 % 0;
      System.out.println("ok");
    } catch (RuntimeException e) {
      System.out.println(e);
    }
    try {
      long a = 2L / 0L;
      System.out.println("ok");
    } catch (RuntimeException e) {
      System.out.println(e);
    }
    System.out.println("Done!");
  }
}
