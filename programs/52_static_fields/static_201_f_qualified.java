/*
Static field, accesed though class qualified expression for read/write.
*/

public class static_201_f_qualified {
  public static void main(String[] args) {
    A.v = 7;
    System.out.println(A.v);
    System.out.println("Done!");
  }
}

class A {
  static int v;
}
