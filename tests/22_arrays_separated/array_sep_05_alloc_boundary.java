/*
Array allocation. Various array dims:
  - positive
  - zero
  - [positive][zero]
  - [zero][positive]
*/

public class array_sep_05_alloc_boundary {

  public static void main(String[] args) {
    new main();
    System.out.println();
    System.out.println("Done!");
  }
}

class main {
  main() {
    int[] vpos = new int[3];
    int[] vzero = new int[0];
    int[] vzero2 = new int[0];
    System.out.print(vzero == vzero2);
    System.out.print(" ");
    int[][] vposzero = new int[3][0];
    System.out.print(vposzero[0] == vposzero[1]);
    int[][] vzeropos = new int[0][3];
  }
}
