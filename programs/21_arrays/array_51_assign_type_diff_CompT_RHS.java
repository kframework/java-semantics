/*
Compile-time type of array element assignment expression = compile-time type of LHS
                                                        != compile-time type of RHS
  Object[] v;
  f(v[0] = new Exception());
  f(v[0]);
*/

public class array_51_assign_type_diff_CompT_RHS {

  public static void main(String[] args) {
    Object[] v = new Object[1];
    f(v[0] = new Exception());
    f(v[0]);

    System.out.println("Done!");
  }

  static void f(Exception a) {
    System.out.println("f(Exception)");
  }

  static void f(Object a) {
    System.out.println("f(Object)");
  }
}
