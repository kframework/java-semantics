/*
Class literals with no packages involved.
  Classes Main and A. Test class literals Object, RuntimeException and A.
*/

public class class_lit_01_no_packages {

  public static void main(String[] args) {
    System.out.println(Object.class.getName());
    System.out.println(RuntimeException.class.getName());
    System.out.println(A.class.getName());
    System.out.println("Done!");
  }
}

class A {}
