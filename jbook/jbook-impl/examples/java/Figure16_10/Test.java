class Test {
  static void m1(Integer i, String s) {
    Comparable x;
    if (i!=null)
      x=i;
    else
      x=s;
    m2(x);
  }

  static void m2(Comparable x) {
  }

  static void main(String[] argv) {
    m1(new Integer(1), "s");
  }
}
