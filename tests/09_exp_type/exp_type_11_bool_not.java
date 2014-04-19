/*
!
boolean b = false, a = true;
!b : !a
*/

public class exp_type_11_bool_not {
  public static void main(String[] args) {
    System.out.println("f(true  ? !get(false) : !get(true)): " + f(true  ? !get(false) : !get(true)));
    System.out.println("f(false ? !get(false) : !get(true)): " + f(false ? !get(false) : !get(true)));

    System.out.println("Done!");
  }

  static String f(boolean b) {
    return "f(boolean): " + b;
  }

  static boolean get(boolean a) {
    System.out.println("get(" + a + ")");
    return a;
  }
}
