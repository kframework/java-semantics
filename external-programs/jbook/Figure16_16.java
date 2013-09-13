class Figure16_16 {
  static boolean m(boolean b) {
    try {
      try { if(b) return b; }
      finally {
        try { if(b) return b; }
        catch (Throwable x) { if (b) return b; }
      }
    } finally { if (b) return b; }
    return b;
  }

  public static void main(String[] argv) {
    m(false);
  }
}
