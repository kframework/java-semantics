/*
Priority of constants is no higher than that of static fields.
  Class B < A.
  A: constant x, static init
  B: field x, static init
  Main: access B.x.
*/

class const_04_priority_2 {
  public static void main(String[] argv) {
    System.out.println("Regular static: " + B.x);
    System.out.println("Constant: " + A.x);
    System.out.println("Done!");
  }
}

class A {
  final static int x = 7;
  static {
    System.out.println("Initialization of A");
  }
}

class B extends A {
  static int x = 3;
  static {
    System.out.println("Initialization of B");
  }
}
