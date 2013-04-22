class Test {
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

  static void main(String[] argv) {
    m(true);
  }
}
   
