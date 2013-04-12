/*
Equality: numeric
int b = 1; long a = 10;
b == b : a == b
b != b : a != b
*/

public class exp_type_20_int_eq {
  public static void main(String[] args) {
    int b = 1; long a = 10;

    System.out.println("f(true  ? b == b : a == b): " + f(true  ? b == b : a == b));
    System.out.println("f(false ? b == b : a == b): " + f(false ? b == b : a == b));
    System.out.println("f(true  ? b != b : a != b): " + f(true  ? b != b : a != b));
    System.out.println("f(false ? b != b : a != b): " + f(false ? b != b : a != b));

    System.out.println("Done!");
  }

  static String f(boolean b) {
    return "f(boolean): " + b;
  }
}
