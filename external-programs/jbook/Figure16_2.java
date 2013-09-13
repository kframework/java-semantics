class Figure16_2 {
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

  public static void main(String[] argv) {
    m(true);
  }
}
