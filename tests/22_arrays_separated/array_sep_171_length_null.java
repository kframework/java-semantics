/*
array.length
  - null.length
*/

public class array_sep_171_length_null {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    int[][] m = new int[3][3];
    m = null;
    try {
      System.out.println(m.length);
    } catch (NullPointerException e) {
      System.out.println(e);
    }
  }
}
