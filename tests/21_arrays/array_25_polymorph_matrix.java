/*
Matrix polymorphism.
    Object[][] mo = new RuntimeException[][];
    mo[0] = new NPE[]. read, write element.
*/

public class array_25_polymorph_matrix {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    Object[][] mo = new RuntimeException[1][1];
    mo[0] = new NullPointerException[2];
    mo[0][0] = new NullPointerException("npe");
    System.out.println(mo[0][0]);
  }

  void printArray(RuntimeException[] v1) {
    for(int i=0; i<v1.length; i++) {
      System.out.print(v1[i] + " ");
    }
    System.out.println();
  }
}
