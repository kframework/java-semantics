class Figure16_7 {
  public static void m(boolean b) {
   try {
     try { if (b) return; }
     finally {
       try { if(b) return; }
       finally { if (b) return; }
     }
   } finally { if (b) return; }
  }

  public static void main(String[] argv) {
    m(true);
  }
}
