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

    System.out.println("f(true  ? b < b : a < b): " + f(true  ? b < b : a < b));
    System.out.println("f(false ? b < b : a < b): " + f(false ? b < b : a < b));
    System.out.println("f(true  ? b > b : a > b): " + f(true  ? b > b : a > b));
    System.out.println("f(false ? b > b : a > b): " + f(false ? b > b : a > b));
    System.out.println("f(true  ? b <= b : a <= b): " + f(true  ? b <= b : a <= b));
    System.out.println("f(false ? b <= b : a <= b): " + f(false ? b <= b : a <= b));

    System.out.println("Done!");
  }

  static String f(boolean b) {
    return "f(boolean): " + b;
  }
}
