class A {
  static int x = 7;
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

class Exercise4_2_5 {
  public static void main(String args[]) {
    System.out.println(B.x);
  }
}
