interface I {
  int c = 1 + A.x;
  int d = 1 + A.y;
}

class A implements I {
  static int x = 2;
  static int y = I.d;
}

class Exercise4_2_7 {
  public static void main(String[] args) {
    System.out.println("I.c = " + I.c);
    System.out.println("I.d = " + I.d);
    System.out.println("A.x = " + A.x);
    System.out.println("A.y = " + A.y);
  }
}
