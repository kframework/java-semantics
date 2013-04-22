class Test {
  public static void main(String[] argv) {
    int[] a;
    try {
     a = (int[])(new Object());
     if (a instanceof int[]) ;
    }
    catch (ClassCastException e) {
     System.out.println(a[0]);
    }
  }
}
