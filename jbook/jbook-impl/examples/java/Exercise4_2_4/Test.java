class A {
  static int x = 7;
  static {
   System.out.println("Initialization of A");
  }
}

class B extends A {
  static {
   System.out.println("Initialization of B");
  }
}

class Test {
  public static void main(String args[]) {
    System.out.println(B.x);
  }
}
