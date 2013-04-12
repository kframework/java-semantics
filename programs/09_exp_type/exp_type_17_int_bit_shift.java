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

    System.out.println("f(true  ? b << 1 : a << 1): " + f(true  ? b << 1 : a << 1));
    System.out.println("f(false ? b << 1 : a << 1): " + f(false ? b << 1 : a << 1));
    System.out.println("f(true  ? b >> 1 : a >> 1): " + f(true  ? b >> 1 : a >> 1));
    System.out.println("f(false ? b >> 1 : a >> 1): " + f(false ? b >> 1 : a >> 1));
    System.out.println("f(true  ? b >>> 1 : a >>> 1): " + f(true  ? b >>> 1 : a >>> 1));
    System.out.println("f(false ? b >>> 1 : a >>> 1): " + f(false ? b >>> 1 : a >>> 1));

    System.out.println("Done!");
  }

  static String f(int b) {
    return "f(int): " + b;
  }

  static String f(long a) {
    return "f(long): " + a;
  }
}
