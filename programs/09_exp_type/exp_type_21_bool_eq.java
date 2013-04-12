/*
Equality: boolean
boolean b = true; boolean a = false;
b == b : a == b
b != b : a != b
*/

public class exp_type_21_bool_eq {
  public static void main(String[] args) {
    boolean b = true; boolean a = false;

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
