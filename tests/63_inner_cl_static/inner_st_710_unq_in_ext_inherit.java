/*
Inner class in extends clause, it's base class is inherited
  by the outer class.
  Classes A, A.InnerA, B < A, B.InnerB < InnerA (referred by simple name).
*/

public class inner_st_710_unq_in_ext_inherit {

  public static void main(String[] args) {
    System.out.println(new B.InnerB());
    System.out.println("Done!");
  }
}

class A {
  static class InnerA {
    public String toString() {
      return "A.InnerA";
    }
  }
}

class B extends A {
  static class InnerB extends InnerA {
    public String toString() {
      return "B.InnerB, base: " + super.toString();
    }
  }
}
