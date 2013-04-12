/*
Logical operators: & ^ |
  boolean b = true; boolean a = false;
  b & b : a & b
  b ^ b : a ^ b
  b | b : a | b
*/

public class exp_type_24_logical_ops {
  public static void main(String[] args) {
     boolean b = true; boolean a = false;

    System.out.println("f(true  ? get(true) & true : get(false) & true): " + f(true  ? get(true) & true : get(false) & true));
    System.out.println("f(false ? get(true) & true : get(false) & true): " + f(false ? get(true) & true : get(false) & true));
    System.out.println("f(true  ? get(true) ^ true : get(false) ^ true): " + f(true  ? get(true) ^ true : get(false) ^ true));
    System.out.println("f(false ? get(true) ^ true : get(false) ^ true): " + f(false ? get(true) ^ true : get(false) ^ true));
    System.out.println("f(true  ? get(true) | true : get(false) | true): " + f(true  ? get(true) | true : get(false) | true));
    System.out.println("f(false ? get(true) | true : get(false) | true): " + f(false ? get(true) | true : get(false) | true));

    System.out.println("Done!");
  }

  static String f(boolean b) {
    return "f(boolean): " + b;
  }

  static boolean get(boolean a) {
    System.out.println("get(" + a + ")");
    return a;
  }
}
