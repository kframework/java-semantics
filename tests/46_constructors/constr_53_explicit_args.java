/*
Two classes, call of superclass constructor with arguments.
*/

class A {
  A(int a, int b) {
    System.out.println("A.A("+a+","+b+")");
  }
}

class B extends A {
  B(int a, int b) {
    super(a-1, b-1);
    System.out.println("B.B("+a+","+b+")");
  }
}

public class constr_53_explicit_args {
  public static void main(String[] args) {
    B b = new B(4,8);
    System.out.println("Done!");
  }
}
