/*
Static method call qualified with a traced object creation.
  Testing that we cannot replace the qualifier with its type for all static method calls.
  Even if qualifier value is not used by the method call, it is still evaluated.
*/

public class static_m_120_qual_traced {
  public static void main(String[] args) {
    new A().sf();
    System.out.println("Done!");
  }
}

class A {

  A() {
    System.out.println("A.A()");
  }

  static void sf() {
    System.out.println("A.sf()");
  }
}
