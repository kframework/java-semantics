class E extends Exception { }

class Test {
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

  static void main(String[] argv) {
    m(true);
  }
}
