interface I {
  int i = 11;
}

class A implements I {
  private static int i = 7;
  void m() {
   i = B.i;
  }

  static public int get() { return i; }
}

class B extends A {
  static void main(String arg[]) {
    System.out.println(A.get());
  }
}

