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

import p1.*;

public class inner_st_701_three_levels {

  public static void main(String[] args) {
    System.out.println("From main:");
    System.out.println(p1.A.Mid.Inner.class.getName());
    System.out.println(A.Mid.Inner.class.getName());
    System.out.println("From p1.A:");
    A.test();
    System.out.println("From p1.A.Test:");
    A.Test.test();
    System.out.println("From p1.A.Mid:");
    A.Mid.test();
    System.out.println("From p1.A.Mid.Inner:");
    A.Mid.Inner.test();

    System.out.println("Done!");
  }
}

