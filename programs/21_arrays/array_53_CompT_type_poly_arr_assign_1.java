/*
Compile-time type of array element access exp don't change after the runtime type of array changes.

  Object[] v = new Object[];
  f(v); f(v[0]);
  v = new Exception[];
  f(v); f(v[0]); - same result
*/

public class array_53_CompT_type_poly_arr_assign_1 {

  public static void main(String[] args) {
    Object[] v = new Object[1];
    f(v); f(v[0]);
    v = new Exception[1];
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
