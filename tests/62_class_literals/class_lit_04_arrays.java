/*
Class literals involving arrays.
  Test Object[].class.getName(),
       A.class.getName(),
       int[].class.getName(),
       int[][].class.getName().
*/

public class class_lit_04_arrays {

  public static void main(String[] args) {
    System.out.println(Object[].class.getName());
    System.out.println(A[].class.getName());
    System.out.println(int[].class.getName());
    System.out.println(int[][].class.getName());
    System.out.println("Done!");
  }
}

class A {}
