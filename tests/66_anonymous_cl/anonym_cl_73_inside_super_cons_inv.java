/*
Anonymous class inside superclass contructor invocation expression. Access parameters and static fields.
*/

public class anonym_cl_73_inside_super_cons_inv {
  public static void main(String[] args) {
    new O(3);
    System.out.println("Done!");
  }
}

interface I1 {}

class A {

  static int a = 1;

  A(I1 i1) {
    System.out.println("A: i1 = "+ i1);
  }
}

class O extends A {

  static int b = 2;

  O(final int c) {
    super(new I1() {
      public String toString() {
        return "anon.toString(): a = "+ a + ", b = "+ b + ", c = "+ c;
      }
    });
  }
}
