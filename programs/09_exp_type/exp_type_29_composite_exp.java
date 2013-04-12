/*
Composite numeric expression.
  1 + (10 + 100) : 1 + (10 + 100L)
*/

public class exp_type_29_composite_exp {
  public static void main(String[] args) {
    int b = 1; long a = 10;

    System.out.println("f(true  ? 1 + (10 + 100) : 1 + (10 + 100L)): " + f(true  ? 1 + (10 + 100) : 1 + (10 + 100L)));
    System.out.println("f(false ? 1 + (10 + 100) : 1 + (10 + 100L)): " + f(false ? 1 + (10 + 100) : 1 + (10 + 100L)));

    System.out.println("Done!");
  }

  static String f(int b) {
    return "f(int): " + b;
  }

  static String f(long a) {
    return "f(long): " + a;
  }
}
