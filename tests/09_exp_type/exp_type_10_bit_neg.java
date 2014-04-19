/*
~
int b = 1; long a = 10;
~b : ~a
*/

public class exp_type_10_bit_neg {
  public static void main(String[] args) {
    int b = 1; long a = 10;

    System.out.println("f(true  ? ~get(1) : ~getL(10)): " + f(true  ? ~get(1) : ~getL(10)));
    System.out.println("f(false ? ~get(1) : ~getL(10)): " + f(false ? ~get(1) : ~getL(10)));

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
