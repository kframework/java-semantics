class Figure16_3 {
  static void m(boolean b) {
    try {
      return;
    } finally {
      while (b) {
        try {
          return;
        } finally {
          if (b) break;
        }
      }
    }
  }

  public static void main(String[] argv) {
    m(true);
  }
}

