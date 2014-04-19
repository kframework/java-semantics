/*
Static field, accessed though class qualified expression for read/write.
*/

public class static_f_101_qualified {
  public static void main(String[] args) {
    A.v = 7;
    System.out.println(A.v);
    System.out.println("Done!");
  }
}

class A {
  static int v;
}
