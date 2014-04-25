/*
Mix of non-"this" qualifier and hiding. Testing the distinction between hiding and overwriting in the case when
  we cannot replace the qualifier with its type.
    B < A.
    B{ static sf()}
    A{ static sf()}
    ((A) new B()).sf();
*/

public class static_m_121_hiding_qual_traced {
  public static void main(String[] args) {
    ((A) new B()).sf();
    System.out.println("Done!");
  }
}

class A {

  static void sf() {
    System.out.println("A.sf()");
  }
}

class B extends A {

  static void sf() {
    System.out.println("B.sf()");
  }
}
