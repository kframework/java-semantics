/*
Compile-time type of array element assignment expression = compile-time type of LHS
                                                        != runtime type of LHS
  Object[] vAux = new Exception[];
  Object[] v;
  f(v[0] = vAux[0]);
  f(v[0]);
*/

public class array_52_assign_type_diff_RunT_RHS {

  public static void main(String[] args) {
    Object[] vAux = new Exception[1];
    Object[] v = new Object[1];
    f(v[0] = vAux[0]);
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
