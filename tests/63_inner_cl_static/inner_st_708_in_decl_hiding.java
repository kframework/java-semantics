/*
Inner classes hiding.
  Classes A, A.Inner, B < A, C < A, C.Inner.
  Access a static field of Inner from A, B, C.
*/

public class inner_st_708_in_decl_hiding {

  public static void main(String[] args) {
    System.out.println(A.getContent());
    System.out.println(B.getContent());
    System.out.println(C.getContent());

    System.out.println("Done!");
  }
}

class A {

  static String getContent() {
    return "A: Inner.x = " + Inner.x;
  }

  public static class Inner {

    static String x = "A.Inner.x";
  }
}

class B extends A {

  static String getContent() {
    return "B: Inner.x = " + Inner.x;
  }
}

class C extends A {

  static String getContent() {
    return "C: Inner.x = " + Inner.x;
  }

  public static class Inner {

    static String x = "C.Inner.x";
  }
}
