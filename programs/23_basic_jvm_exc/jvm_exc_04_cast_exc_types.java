/*
ClassCastException types.
  - (String) (obj)(UserClass)
  - (String) (obj)(array)
  - (array)  (obj)(UserClass)
  - (array)  (obj)(String)
  - (UserClass) (obj)(String)
  - (UserClass) (obj)(array)
*/

class UserClass {}

public class jvm_exc_04_cast_exc_types {
  public static void main(String[] args) {
    try {
      Object a = new UserClass();
      System.out.println((String)a);
    } catch (RuntimeException e) {
      System.out.println(e);
    }
    try {
      Object a = new int[0];
      System.out.println((String)a);
    } catch (RuntimeException e) {
      System.out.println(e);
    }
    try {
      Object a = new UserClass();
      System.out.println((int[])a);
    } catch (RuntimeException e) {
      System.out.println(e);
    }
    try {
      Object a = "abc";
      System.out.println((int[])a);
    } catch (RuntimeException e) {
      System.out.println(e);
    }
    try {
      Object a = "abc";
      System.out.println((UserClass)a);
    } catch (RuntimeException e) {
      System.out.println(e);
    }
    try {
      Object a = new int[0];
      System.out.println((UserClass)a);
    } catch (RuntimeException e) {
      System.out.println(e);
    }

    System.out.println("Done!");
  }
}
