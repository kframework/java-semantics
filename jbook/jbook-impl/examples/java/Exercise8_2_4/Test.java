class Test {
  static int m(int i) {
    if (i<0) return 0;
    else 
     while (i >= 0) {
       if (i==0) return 1;
       i = i - 1;
     }
    return 0;
  }

  static public void main(String[] argv) { 
    m(2); 
  }
}
