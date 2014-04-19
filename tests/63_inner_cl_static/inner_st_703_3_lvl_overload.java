/*
Overloading with three-level class nesting.
  Classes:
    - A
    - A.Mid
    - A.Mid.Inner
  Members:
    - A.f(short)
    - Mid.f(int)
    - Inner.f(long)
  Call f(long), f(int), f(byte) from Inner.
*/

public class inner_st_703_3_lvl_overload {

  public static void main(String[] args) {
    A.Mid.Inner.test();

    System.out.println("Done!");
  }
}

class A {

  static String f(short a) {
    return "A.f(short)";
  }

  public static class Mid {

    static String f(int a) {
      return "A.Mid.f(int)";
    }

    public static class Inner {

      static String f(long a) {
        return "A.Mid.Inner.f(long)";
      }

      static void test() {
        System.out.println("byte arg: " + f((byte)0));
        System.out.println("int arg:  " + f((int)0));
        System.out.println("long arg: " + f((long)0));
      }
    }
  }
}
