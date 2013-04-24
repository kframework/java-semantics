/*
Array variable, [] as part of the declarator (compatibility with C):
  - int[] b[]. Assign, access.
  - int[] b[][]. Assign, access.
  - int[][] b[][] = new[][][][]. Assign, access.
*/

public class array_09_decl_C_style {

  public static void main(String[] args) {
    new main();
    System.out.println();
    System.out.println("Done!");
  }
}

class main {
  main() {
    int[] m[];
    m = new int[2][2];

    m[0][0] = 44;
    System.out.println(m[0][0]);

    int[] m3[][];
    m3 = new int[1][1][1];
    m3[0][0][0] = 555;
    System.out.println(m3[0][0][0]);

    int[][] m4[][] = new int[1][1][1][1];

    m4[0][0][0][0] = 6666;
    System.out.println(m4[0][0][0][0]);

    int a = 1, v[] = new int[3];
    v[1] = a;
    System.out.println(a + " " + v[1]);
  }
}
