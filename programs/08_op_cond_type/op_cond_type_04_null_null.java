/*
Conditional with both types null.
  Pairs: null null
  Args: Object, A
*/

public class op_cond_type_04_null_null {
  public static void main(String[] args) {
    System.out.println("null  null : " + f(true ? null : null));
    System.out.println("Done!");
  }

  static String f(A a) {
    return "A";
  }

  static String f(Object a) {
    return "Object";
  }
}

class A {}

