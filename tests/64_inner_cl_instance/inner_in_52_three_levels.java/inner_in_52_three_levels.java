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

import p1.*;

public class inner_in_52_three_levels {

  public static void main(String[] args) {
    System.out.println("From main:");
    System.out.println(p1.A.Mid.Inner.class.getName());
    System.out.println(A.Mid.Inner.class.getName());
    System.out.println("From p1.A:");
    A a = new A();
    a.test();
    System.out.println("From p1.A.Test:");
    a.new Test().test();
    System.out.println("From p1.A.Mid:");
    A.Mid mid = a.new Mid();
    mid.test();
    System.out.println("From p1.A.Mid.Inner:");
    mid.new Inner().test();

    System.out.println("Done!");
  }
}

