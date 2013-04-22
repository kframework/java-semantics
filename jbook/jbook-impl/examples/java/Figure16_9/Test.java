class Test {
  static int m(boolean b) {
   int i;
   L: {
       try {
        if (b) return 1;
        i = 2;
        if (b) break L;
       } finally { if (b) i = 3; }
       i = 4;
      }
   return i;
  }

  static void main(String[] argv) { 
   m(true);
  }
}
