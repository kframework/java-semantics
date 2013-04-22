class Test {
  int m() {
   l: try {
       break l;
      } finally { return 0; }
  }

  static public void main(String[] argv) { }
}
