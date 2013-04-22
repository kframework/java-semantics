class E extends Exception {
}

class Test {
  public static void main(String[] argv) {
    try {
     try { throw new E(); } finally { return; }
    } catch (E x) { return; }
  }
}
    
