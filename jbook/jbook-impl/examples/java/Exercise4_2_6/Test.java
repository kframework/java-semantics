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

class Test {
  public static void main(String[] argv) {
    System.out.println(B.x);
  }
}
