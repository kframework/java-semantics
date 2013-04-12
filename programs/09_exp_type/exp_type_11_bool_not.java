/*
!
boolean b = false, a = true;
!b : !a
*/

public class exp_type_11_bool_not {
  public static void main(String[] args) {
    boolean b = false, a = true;

    System.out.println("f(true  ? !b : !a): " + f(true  ? !b : !a));
    System.out.println("f(false ? !b : !a): " + f(false ? !b : !a));

    System.out.println("Done!");
  }

  static String f(boolean b) {
    return "f(boolean): " + b;
  }
}
