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

class Exercise4_2_6 {
  public static void main(String[] argv) {
    System.out.println(B.x);
  }
}
