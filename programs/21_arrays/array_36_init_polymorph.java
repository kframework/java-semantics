/*
Array assign compatibility test:
  new Object[][]{new RuntimeException[] {new RuntimeException("re")} }
*/

public class array_36_init_polymorph {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    Object[][] m;
    m = new Object[][]{new RuntimeException[] {new RuntimeException("re")} };
    printMatrix(m);
  }

  void printArray(Object[] v1) {
    if (v1 == null) {
      System.out.println(v1);
    } else {
      for(int i=0; i<v1.length; i++) {
        System.out.print(v1[i] + " ");
      }
      System.out.println();
    }
  }

  void printMatrix(Object[][] m) {
    for(int i=0; i<m.length; i++) {
      printArray(m[i]);
    }
    System.out.println();
  }
}
