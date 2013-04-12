/*
Array access expression
  B < A
  B[] vb; A[] va;
  vb[0] : va[0]
*/

public class exp_type_06_array_access {
  public static void main(String[] args) {
    B[] vb = new B[1];
    vb[0] = new B();
    A[] va = new A[1];
    va[0] = new A();

    System.out.println("f(true  ? vb[0] : va[0]): " + f(true  ? vb[0] : va[0]));
    System.out.println("f(false ? vb[0] : va[0]): " + f(false ? vb[0] : va[0]));
    System.out.println("Done!");
  }

  static String f(B b) {
    return "f(B): " + b;
  }

  static String f(A a) {
    return "f(A): " + a;
  }
}

class A {
  public String toString() {
    return "A";
  }
}

class B extends A {
  public String toString() {
    return "B";
  }
}
