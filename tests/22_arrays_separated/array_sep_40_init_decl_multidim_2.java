/*
Array initializer as part of array var declaration:

Two dims, dim count cannot be deduced from initializer:
  - int[][][] m = {null,null}, assign a valid array, test
  - int[] m[][] = {null,null}, assign a valid array, test
*/

public class array_sep_40_init_decl_multidim_2 {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    int[][] m = {{1}, {2}};
    int[][][] m31 = {null, null};
    m31[0] = m;
    printMatrix3(m31);

    int[] m32[][] = {null, null};
    m32[0] = m;
    printMatrix3(m32);
  }

  void printArray(int[] v1) {
    if (v1 == null) {
      System.out.println(v1);
    } else {
      for(int i=0; i<v1.length; i++) {
        System.out.print(v1[i] + " ");
      }
      System.out.println();
    }
  }

  void printMatrix(int[][] m) {
    if (m == null) {
      System.out.println(m);
    } else {
      for(int i=0; i<m.length; i++) {
        printArray(m[i]);
      }
      System.out.println();
    }
  }

  void printMatrix3(int[][][] m3) {
    if (m3 == null) {
      System.out.println(m3);
    } else {
    for(int i=0; i<m3.length; i++) {
      printMatrix(m3[i]);
    }
    System.out.println();
    }
  }
}
