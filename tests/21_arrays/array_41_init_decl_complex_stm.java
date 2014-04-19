/*
Array initializer as part of array var declaration:

Combination of multi var declaration, var with [] in declarator, array initializer.
*/

public class array_41_init_decl_complex_stm {

  public static void main(String[] args) {
    new Test();
    System.out.println("Done!");
  }
}

class Test {
  Test() {
    int[] v = {1, 2}, m[] = new int[][]{{3,4}, {5+6}, null}, m2[] = {{7}, {}, null}, m3[];
    m3 = null;
    printArray(v);
    printMatrix(m);
    printMatrix(m2);
    printMatrix(m3);
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
}
