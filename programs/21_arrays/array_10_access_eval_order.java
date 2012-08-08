/*
10. Array access evaluation order:
  - [++i][++i][++i]
  - [2/0][negative] - throws ArithmeticException.
*/

public class array_10_access_eval_order {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main() {
  main() {
    int[][][] m = new int[1][2][3];

    int i = -1;
    v[++i][++i][++i] = i;
    System.out.println(v[0][1][2]);

    try {
      v[2/0][-2] = -2;
      System.out.println("ok");
    } catch(RuntimeException re) {
      System.out.println(re);
    }
  }
}
