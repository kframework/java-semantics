/*
Array assign compatibility test:
  new Object[][]{new RuntimeException[] {new RuntimeException("re")} }
*/

public class array_sep_36_init_polymorph {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    Object[][] m;
    m = new Object[][]{new RuntimeException[] {new RuntimeException()} };
    printMatrix(m);
  }

  void printArray(Object[] v1) {
    if (v1 == null) {
      System.out.println(v1);
    } else {
      for(int i=0; i<1; i++) {
        System.out.print(v1[i] + " ");
      }
      System.out.println();
    }
  }

  void printMatrix(Object[][] m) {
    for(int i=0; i<1; i++) {
      printArray(m[i]);
    }
    System.out.println();
  }
}
