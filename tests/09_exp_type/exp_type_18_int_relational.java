/*
Relational numeric operators: < > <= >=
int b = 1; long a = 10;
b < b : a < b
b > b : a > b
b <= b : a <= b
b >= b : a >= b
*/

public class exp_type_18_int_relational {
  public static void main(String[] args) {
    int b = 10; long a = 100;

    System.out.println("f(true  ? get(10) < 10 : getL(100) < 10): " + f(true  ? get(10) < 10 : getL(100) < 10));
    System.out.println("f(false ? get(10) < 10 : getL(100) < 10): " + f(false ? get(10) < 10 : getL(100) < 10));
    System.out.println("f(true  ? get(10) > 10 : getL(100) > 10): " + f(true  ? get(10) > 10 : getL(100) > 10));
    System.out.println("f(false ? get(10) > 10 : getL(100) > 10): " + f(false ? get(10) > 10 : getL(100) > 10));
    System.out.println("f(true  ? get(10) <= 10 : getL(100) <= 10): " + f(true  ? get(10) <= 10 : getL(100) <= 10));
    System.out.println("f(false ? get(10) <= 10 : getL(100) <= 10): " + f(false ? get(10) <= 10 : getL(100) <= 10));
    System.out.println("f(true  ? get(10) >= 10 : getL(100) >= 10): " + f(true  ? get(10) >= 10 : getL(100) >= 10));
    System.out.println("f(false ? get(10) >= 10 : getL(100) >= 10): " + f(false ? get(10) >= 10 : getL(100) >= 10));

    System.out.println("Done!");
  }

  static String f(boolean b) {
    return "f(boolean): " + b;
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
