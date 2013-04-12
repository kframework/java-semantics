/*
new array expression:
B < A,
new B[1] : new A[2]
f(): print array length
*/

public class exp_type_03_new_array {
  public static void main(String[] args) {
    System.out.println("f(true  ? new B[1] : new A[2]): " + f(true  ? new B[1] : new A[2]));
    System.out.println("f(false ? new B[1] : new A[2]): " + f(false ? new B[1] : new A[2]));
    System.out.println("Done!");
  }

  static String f(B[] vb) {
    return "f(B[]): " + vb.length;
  }

  static String f(A[] va) {
    return "f(A[]): " + va.length;
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
