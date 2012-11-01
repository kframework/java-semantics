/*
Static field, accessed through unqualified expression in static methods,
  for read/write.
*/

public class static_202_f_unqualified {
  public static void main(String[] args) {
    A.setV(7);
    System.out.println(A.getV());
    System.out.println("Done!");
  }
}

class A {
  private static int v;

  static int getV() {
    return v;
  }

  static void setV(int paramv) {
    v = paramv;
  }
}
