/*
Array element type preservation.
  Check that the type of element of an array of primitives does not change
    after assignment of a literal of narrower type.
  - long[] a; a[0] = 2.000.000.000. print(a[0]+a[0]) - should print 4.000.000.000
  - long[][] m. Same test for two-dim array.
*/

public class array_02_assign_type_preserv {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    long[] v = new long[1];
    v[0] = 2100100100;
    System.out.println(v[0]+v[0]);

    long[][] m = new long[1][1];
    m[0][0] = 2100100100;
    System.out.println(m[0][0]+m[0][0]);
  }
}
