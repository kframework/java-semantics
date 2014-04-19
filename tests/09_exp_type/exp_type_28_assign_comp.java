/*
Assignment: some compound
int b = 1; long a = 10;
b += 200 : a += 200
b -= 2 : a -= 2
Print a, b after each assign.
*/

public class exp_type_28_assign_comp {
  public static void main(String[] args) {
    int b = 1; long a = 10;

    System.out.println("f(true  ? (b += 200) : (a += 200)): " + f(true  ? (b += 200) : (a += 200)));
    System.out.println("(b a) = (" + b + " " + a + ")");
    System.out.println("f(false ? (b += 200) : (a += 200)): " + f(false ? (b += 200) : (a += 200)));
    System.out.println("(b a) = (" + b + " " + a + ")");
    System.out.println("f(true  ? (b -= 2) : (a -= 2)): " + f(true  ? (b -= 2) : (a -= 2)));
    System.out.println("(b a) = (" + b + " " + a + ")");
    System.out.println("f(false ? (b -= 2) : (a -= 2)): " + f(false ? (b -= 2) : (a -= 2)));
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
