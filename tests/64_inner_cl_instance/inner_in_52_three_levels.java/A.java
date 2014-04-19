/*
Three-level class nesting. (Similar to static inner 701)
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

  public String toString() {
    return "p1.A";
  }

  public void test() {
    System.out.println(new p1.A().new Mid().new Inner());
    System.out.println(new A().new Mid().new Inner());
    System.out.println(new Mid().new Inner());
  }

  public class Mid {

    public String toString() {
      return "p1.A.Mid";
    }

    public void test() {
      System.out.println(new p1.A().new Mid().new Inner());
      System.out.println(new A().new Mid().new Inner());
      System.out.println(new Mid().new Inner());
      System.out.println(new Inner());
    }

    public class Inner {

      public String toString() {
        return "p1.A.Mid.Inner";
      }

      public void test() {
        System.out.println(new p1.A().new Mid().new Inner());
        System.out.println(new A().new Mid().new Inner());
        System.out.println(new Mid().new Inner());
        System.out.println(new Inner());
        System.out.println(new A());
        System.out.println(new Mid());
        System.out.println(new Test());
      }
    }
  }

  public class Test {

    public String toString() {
      return "p1.Test";
    }

    public void test() {
      System.out.println(new p1.A().new Mid().new Inner());
      System.out.println(new A().new Mid().new Inner());
      System.out.println(new Mid().new Inner());
    }
  }
}
