// Example adapted from R. Staerk
class Stars {
  public static void main(String[] argv) {
    int MAX = 8;
    for (int m = MAX, n = 1; 0 < m; m--, n = n + 2) {
      for (int i = 0; i < m; i++)
        System.out.print(" ");
      for (int i = 0; i < n; i++)
        System.out.print("*");
      System.out.println("");
    }
  }
}


