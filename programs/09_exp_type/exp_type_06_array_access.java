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
    A[] va = new A[2];
    va[1] = new A();

    System.out.println("f(true  ? vb[get(0)] : va[get(1)]): " + f(true  ? vb[get(0)] : va[get(1)]));
    System.out.println("f(false ? vb[get(0)] : va[get(1)]): " + f(false ? vb[get(0)] : va[get(1)]));
    System.out.println("Done!");
  }

  static String f(B b) {
    return "f(B): " + b;
  }

  static String f(A a) {
    return "f(A): " + a;
  }

  static int get(int a) {
    System.out.println("get(" + a + ")");
    return a;
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
