/*
7. Matrixes:
  int[][], boolean[][], String[][], RuntimeException[][], Object[][][]
*/

public class className_07_array_multidim {
  public static void main(String[] args) {
    System.out.println(new     int[0][ ].getClass().getName());
    System.out.println(new boolean[1][0].getClass().getName());
    System.out.println(new String[0][].getClass().getName());
    System.out.println(new RuntimeException[0][].getClass().getName());
    System.out.println(new Object[0][][].getClass().getName());

    System.out.println("\nDone!");
  }
}
