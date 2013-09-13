class Figure16_5 {
  public static void main(String[] argv) { m(true); }
  static void m(boolean b) {
    while (true) {
      try {
        if (b) return;
      } finally {
        if (b) break;
      }
    }
    b = true;
  }
}
