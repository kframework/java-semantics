/*
Equality: numeric
int b = 1; long a = 10;
b == b : a == b
b != b : a != b
*/

public class exp_type_20_int_eq {
  public static void main(String[] args) {
    int b = 1; long a = 10;

    System.out.println("f(true  ? get(1) == 1 : getL(10) == 1): " + f(true  ? get(1) == 1 : getL(10) == 1));
    System.out.println("f(false ? get(1) == 1 : getL(10) == 1): " + f(false ? get(1) == 1 : getL(10) == 1));
    System.out.println("f(true  ? get(1) != 1 : getL(10) != 1): " + f(true  ? get(1) != 1 : getL(10) != 1));
    System.out.println("f(false ? get(1) != 1 : getL(10) != 1): " + f(false ? get(1) != 1 : getL(10) != 1));

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
