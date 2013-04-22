class Test {
  static void m(boolean b) {
   try {
     try { if (b) return; }
     finally {
       try { if(b) return; }
       finally { if (b) return; }
     }
   } finally { if (b) return; }
  }

  static void main(String[] argv) {
    m(true);
  }
}
