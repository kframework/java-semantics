/*
Array access evaluation order:
  - [++i][++i][++i]
  - [2/0][negative] - throws ArithmeticException.
*/

public class array_sep_12_access_eval_order {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    int[][][] m = new int[1][2][3];

    int i = 0;
    m[i++][i++][i++] = i;
    System.out.println(m[0][1][2]);

    try {
      m[2/0][-2][0] = -2;
      System.out.println("ok");
    } catch(RuntimeException re) {
      System.out.println(re);
    }
  }
}
