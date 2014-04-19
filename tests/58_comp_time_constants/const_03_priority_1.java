/*
Priority of fields is no higher than that of constants. The test from JBook:
  Class B < A.
  A: field x, static init
  B: constant x, static init
  Main: access B.x.
*/

class const_03_priority_1 {
  public static void main(String[] argv) {
    System.out.println("Constant: " + B.x);
    System.out.println("Done!");
  }
}

class A {
  static int x = 7;
  static {
    System.out.println("Initialization of A");
  }
}

class B extends A {
  static final int x = 3;
  static {
    System.out.println("Initialization of B");
  }
}
