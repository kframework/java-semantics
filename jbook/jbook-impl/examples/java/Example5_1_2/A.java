class A {
  private int x;
  private int y = 17;
  static int z = 3;

  A(int x) {
    this.x = x;
  }

  static void main(String[] argv) {
    A a = new A(5);
  }
}
