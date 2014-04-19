/*
Hierarchy type A < I1. A class init accesses fields in I1 unqualified.
  static sequence in A: {trace} {access to I1} {trace}. Static sequence of I1 is also traced.
*/

public class interface_f_83_hier_class_impl_interf {
  public static void main(String[] args) {
    System.out.println("A.c = " + A.c);
    System.out.println("Done!");
  }
}

interface I1 {
  int a = Auxx.trace(1);
  int b = Auxx.trace(2);
}

class A implements I1 {

  static {
    Auxx.trace(10);
  }

  static int c = Auxx.trace(a + 20);

  static {
    Auxx.trace(30);
  }
}

class Auxx {
  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }
}
