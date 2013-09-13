class E extends Exception { }

class Figure16_4 {
  static void m(boolean b) {
    try {
      try {
        return;
      } finally {
        if (b) throw new E();
      }
    } catch (E x) {
      System.out.println("Exception caught.");
      return;
    }
  }

  public static void main(String[] argv) {
    m(true);
  }
}
