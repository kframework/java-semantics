/*
6. Order of dims during allocation:
  - [++i][++i][++i]
  - [negative][2/0] - should throw ArithmeticException.
    All dims are first evaluated, then checked.
*/

public class array_06_alloc_order_of_dims {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main() {
  main() {
    int i = 0;
    int[][][] m = new int[++i][++i][++i];

    m[1][2][3] = 123;
    System.out.println(m[1][2][3]);

    try {
      m = new int[-2][2/0][4];
    } catch (RuntimeException re) {
      System.out.println(re);
    }
  }
}
