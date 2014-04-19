/*
Assign among arrays. Multidim arrays.
  - A[][]. B[]. A[1] = B. Test.
  - A[][][]. B[][], A[1] = B. Test final value.
  - A[1][1] = B[1]. Test
*/

public class array_sep_16_assign_multidim {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    int[][] m = new int[3][];
    int[] v = new int[1];
    v[0] = 12;
    m[1] = v;
    System.out.println(m[1][0]);

    int[][][] m3 = new int[2][][];
    m3[1] = m;
    System.out.println(m3[1][1][0]);

    int[][] m2 = new int[1][1];
    m2[0][0] = 11;
    m3[1][1] = m2[0];
    System.out.println(m3[1][1][0]);
  }
}
