/*
Assignment operator simple
int b = 1; long a = 10;
b = 2 : a = 20
Print a, b after assign.
*/

public class exp_type_27_assign {
  public static void main(String[] args) {
    int b = 1; long a = 10;

    System.out.println("f(true  ? (b = 2) : (a = 20)): " + f(true  ? (b = 2) : (a = 20)));
    System.out.println("(b a) = (" + b + " " + a + ")");
    System.out.println("f(false ? (b = 2) : (a = 20)): " + f(false ? (b = 2) : (a = 20)));
    System.out.println("(b a) = (" + b + " " + a + ")");

    System.out.println("Done!");
  }

  static String f(int b) {
    return "f(int): " + b;
  }

  static String f(long a) {
    return "f(long): " + a;
  }
}
