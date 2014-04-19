/*
Class with a constant initialized with an int value and static initializer printing something.
  Access the constant. Static init should not be triggered.
  Access a non-constant static field. Static init should be triggered. Access the constant again.
*/

class const_01_in_class {
  public static void main(String[] argv) {
    System.out.println("Constant: " + B.x);
    System.out.println("Regular static: " + B.y);
    System.out.println("Constant: " + B.x);
    System.out.println("Done!");
  }
}

class B {
  static final int x = 3;
  static int y = 10;
  static {
    System.out.println("Initialization of B");
  }
}
