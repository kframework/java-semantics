/*
Multiplicative operators: * / %
int b = 10; long a = 100;
b * b : a * b
b / b : a / b
b % b : a % b
*/

public class exp_type_14_int_multi {
  public static void main(String[] args) {
    int b = 10; long a = 100;

    System.out.println("f(true  ? b * b : a * b): " + f(true  ? b * b : a * b));
    System.out.println("f(false ? b * b : a * b): " + f(false ? b * b : a * b));
    System.out.println("f(true  ? b / b : a / b): " + f(true  ? b / b : a / b));
    System.out.println("f(false ? b / b : a / b): " + f(false ? b / b : a / b));
    System.out.println("f(true  ? b % b : a % b): " + f(true  ? b % b : a % b));
    System.out.println("f(false ? b % b : a % b): " + f(false ? b % b : a % b));

    System.out.println("Done!");
  }

  static String f(int b) {
    return "f(int): " + b;
  }

  static String f(long a) {
    return "f(long): " + a;
  }
}
