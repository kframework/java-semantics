/*
Members in three-level class nesting.
  Classes:
    - A
    - A.Mid
    - A.Mid.Inner
  Members:
    - A.a
    - A.Mid.b
    - A.Mid.Inner.c
  Access a,b,c from Inner
*/

public class inner_st_702_3_lvl_members {

  public static void main(String[] args) {
    A.Mid.Inner.test();

    System.out.println("Done!");
  }
}

class A {

  static String a = "A.a";

  public static class Mid {

    static String b = "Mid.b";

    public static class Inner {

      static String c = "Inner.c";

      static void test() {
        System.out.println(a + " " + b + " " + c);
      }
    }
  }
}
