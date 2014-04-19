/*
Testing equality of class literal objects, also after multiple expression calls.
    class p1.A
    Main imports p1.*;

    Test that Object.class == java.lang.Object.class

    A.class == A.class,
    A.class = p1.A class
*/

import p1.*;

public class class_lit_05_ref_equality {

  public static void main(String[] args) {
    System.out.println(Object.class == java.lang.Object.class);
    System.out.println(A.class == A.class);
    System.out.println(A.class == p1.A.class);
    System.out.println("Done!");
  }
}
