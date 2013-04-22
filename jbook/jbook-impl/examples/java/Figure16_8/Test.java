class Test {
  static int m(boolean b) {
   int i;
   try {
    if (b) return 1;
    i = 2;
   } finally { if (b) i = 3; }
   return i;
  }
 
  static void main(String[] argv) {
   m(false);
  }
}
