class Test {
  static void m(boolean b) {
    while (b) {
      try {
       return;
      } finally {
        if (b) break;
      }
    }
    System.out.println("return ignored");
  }

  static void main(String[] argv) {
    m(true);
  }
}
