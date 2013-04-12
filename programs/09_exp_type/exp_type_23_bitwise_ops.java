/*
Bitwise operators: & ^ |
int b = 1; long a = 10;
b & b : a & b
b ^ b : a ^ b
b | b : a | b
*/

public class exp_type_23_bitwise_ops {
  public static void main(String[] args) {
    int b = 1; long a = 10;

    System.out.println("f(true  ? b & b : a & b): " + f(true  ? b & b : a & b));
    System.out.println("f(false ? b & b : a & b): " + f(false ? b & b : a & b));
    System.out.println("f(true  ? b ^ b : a ^ b): " + f(true  ? b ^ b : a ^ b));
    System.out.println("f(false ? b ^ b : a ^ b): " + f(false ? b ^ b : a ^ b));
    System.out.println("f(true  ? b | b : a | b): " + f(true  ? b | b : a | b));
    System.out.println("f(false ? b | b : a | b): " + f(false ? b | b : a | b));

    System.out.println("Done!");
  }

  static String f(int b) {
    return "f(int): " + b;
  }

  static String f(long a) {
    return "f(long): " + a;
  }
}
