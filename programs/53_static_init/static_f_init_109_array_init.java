/*
Array fields with array initializer in the most complex fashion:
Combination of multi field declaration, field with [] in declarator, array initializer.
*/

public class static_f_init_109_array_init {

  public static void main(String[] args) {
    new test();
    System.out.println("Done!");
  }
}

class test {

  static int[] v = {1, 2}, m[] = {{3,4}, {5+6}, null}, m2[] = {{7}, {}, null};

  test() {
    printArray(v);
    printMatrix(m);
    printMatrix(m2);
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
    for(int i=0; i<m.length; i++) {
      printArray(m[i]);
    }
    System.out.println();
  }
}
