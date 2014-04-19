/*
array.length
  - one dim, positive
  - one dim, zero
  - two dims, positive
  - two dims, second dim assigned, positive
  - two dims, second dim assigned, zero
  - null.length
*/

public class array_17_length {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    int[] v = new int[4];
    System.out.println(v.length);
    v = new int[0];
    System.out.println(v.length);

    int[][] m = new int[3][3];
    m[1] = new int[0];
    m[2] = v;
    for(int i=0; i<m.length; i++) {
      System.out.print(m[i].length + " ");
    }
    System.out.println();

    m = null;
    try {
      System.out.println(m.length);
    } catch (NullPointerException e) {
      System.out.println(e);
    }
  }
}
