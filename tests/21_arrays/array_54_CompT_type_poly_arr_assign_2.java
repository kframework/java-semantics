/*
Compile-time type of array element access exp don't change after the runtime type of array changes,
  even if assignment LHS have the same compile-time type as RHS.

  Object[] vAux = new Exception[];
  Object[] v = new Object[];
  f(v); f(v[0]);
  v = vAux;
  f(v); f(v[0]); - same result
*/

public class array_54_CompT_type_poly_arr_assign_2 {

  public static void main(String[] args) {
    Object[] vAux = new Exception[1];
    Object[] v = new Object[1];
    f(v); f(v[0]);
    v = vAux;
    f(v); f(v[0]); // same result

    System.out.println("Done!");
  }

  static void f(Exception a) {
    System.out.println("f(Exception)");
  }

  static void f(Object a) {
    System.out.println("f(Object)");
  }

  static void f(Exception[] a) {
    System.out.println("f(Exception[])");
  }

  static void f(Object[] a) {
    System.out.println("f(Object[])");
  }
}
