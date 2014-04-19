/*
Composite numeric expression.
  1 + (10 + 100) : 1 + (10 + 100L)
*/

public class exp_type_29_composite_exp {
  public static void main(String[] args) {
    int b = 1; long a = 10;

    System.out.println("f(true  ? get(1) + (10 + 100) : get(2) + (10 + 100L)): " + f(true  ? get(1) + (10 + 100) : get(2) + (10 + 100L)));
    System.out.println("f(false ? get(1) + (10 + 100) : get(2) + (10 + 100L)): " + f(false ? get(1) + (10 + 100) : get(2) + (10 + 100L)));

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
}
