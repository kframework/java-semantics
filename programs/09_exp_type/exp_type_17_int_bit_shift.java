/*
Shift operators: << >> >>>
int b = 10; long a = 100;
b << 1 : a << 1
b >> 1 : a >> 1
b >>> 1 : a >>> 1
*/

public class exp_type_17_int_bit_shift {
  public static void main(String[] args) {
    int b = 10; long a = 100;

    System.out.println("f(true  ? get(10) << 1 : getL(100) << 1): " + f(true  ? get(10) << 1 : getL(100) << 1));
    System.out.println("f(false ? get(10) << 1 : getL(100) << 1): " + f(false ? get(10) << 1 : getL(100) << 1));
    System.out.println("f(true  ? get(10) >> 1 : getL(100) >> 1): " + f(true  ? get(10) >> 1 : getL(100) >> 1));
    System.out.println("f(false ? get(10) >> 1 : getL(100) >> 1): " + f(false ? get(10) >> 1 : getL(100) >> 1));
    System.out.println("f(true  ? get(10) >>> 1 : getL(100) >>> 1): " + f(true  ? get(10) >>> 1 : getL(100) >>> 1));
    System.out.println("f(false ? get(10) >>> 1 : getL(100) >>> 1): " + f(false ? get(10) >>> 1 : getL(100) >>> 1));

    System.out.println("Done!");
  }

  static String f(int b) {
    return "f(int): " + b;
  }

  static String f(long a) {
    return "f(long): " + a;
  }

  static int get(int a) {
    System.out.println("get(" + a + ")");
    return a;
  }

  static long getL(long a) {
    System.out.println("getL(" + a + ")");
    return a;
  }
}
