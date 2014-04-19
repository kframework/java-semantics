/*
Double is larger than any other numeric type.
  Method f(double).
  Call the method with arguments byte, short, int, long ,char, float, double.
*/

public class float_52_double_sub_of_types {
  public static void main(String[] args) {
    f((byte) 100);
    f((short) 100);
    f((int) 100);
    f((long) 100);
    f((char) 100);
    f((float) 100);
    f((double) 100);
    System.out.println("Done!");
  }

  static void f(double a) {
    System.out.println("double a = " + a);
  }
}
