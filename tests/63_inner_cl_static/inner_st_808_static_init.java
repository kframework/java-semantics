/*
Static init of an inner class.
  Classes A, A.Inner1. B, B.Inner2. Static init trace for A, A.Inner1, B, B.Inner2.
  From main call A.Inner1.id, B.id. See static initialization in classes A.Inner1, B.
*/

public class inner_st_808_static_init {

  public static void main(String[] args) {
    System.out.println(A.Inner1.id);
    System.out.println(B.id);

    System.out.println("Done!");
  }
}

class A {

  static {
    System.out.println("A: static init");
  }

  static class Inner1 {

    static {
      System.out.println("A.Inner1: static init");
    }

    static String id = "A.Inner1.id";
  }
}

class B {

  static String id = "B.id";

  static {
    System.out.println("B: static init");
  }

  static class Inner2 {
    static {
      System.out.println("B.Inner2: static init");
    }
  }
}
