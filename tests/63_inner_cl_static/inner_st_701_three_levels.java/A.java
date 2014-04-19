/*
Three-level class nesting.
  Classes:
    - p1.A
    - p1.A.Mid
    - p1.A.Mid.Inner
    - p1.A.Test
  .class the following names:
    - from main (imports p1):
      - p1.A.Mid.Inner
      - A.Mid.Inner
    - from p1.A:
      - p1.A.Mid.Inner
      - A.Mid.Inner
      - Mid.Inner
      - Inner
    - from p1.A.Test:
      - p1.A.Mid.Inner
      - A.Mid.Inner
      - Mid.Inner
      - Inner
    - from p1.A.Mid:
      - p1.A.Mid.Inner
      - A.Mid.Inner
      - Mid.Inner
      - Inner
    - from p1.A.Mid.Inner:
      - p1.A.Mid.Inner
      - A.Mid.Inner
      - Mid.Inner
      - Inner
      - A
      - Mid
      - Test
*/

package p1;

public class A {

  public static void test() {
    System.out.println(p1.A.Mid.Inner.class.getName());
    System.out.println(A.Mid.Inner.class.getName());
    System.out.println(Mid.Inner.class.getName());
  }

  public static class Mid {

    public static void test() {
      System.out.println(p1.A.Mid.Inner.class.getName());
      System.out.println(A.Mid.Inner.class.getName());
      System.out.println(Mid.Inner.class.getName());
      System.out.println(Inner.class.getName());
    }

    public static class Inner {
      public static void test() {
        System.out.println(p1.A.Mid.Inner.class.getName());
        System.out.println(A.Mid.Inner.class.getName());
        System.out.println(Mid.Inner.class.getName());
        System.out.println(Inner.class.getName());
        System.out.println(A.class.getName());
        System.out.println(Mid.class.getName());
        System.out.println(Test.class.getName());
      }
    }
  }

  public static class Test {
    public static void test() {
      System.out.println(p1.A.Mid.Inner.class.getName());
      System.out.println(A.Mid.Inner.class.getName());
      System.out.println(Mid.Inner.class.getName());
    }
  }
}
