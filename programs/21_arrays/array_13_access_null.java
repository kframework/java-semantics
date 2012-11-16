/*
Array access null.
  - null[2] - throws NullPointerException. Read, write.
*/

public class array_13_access_null {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    int[] v = null;

    try {
      int a = v[2];
      System.out.println("ok");
    } catch(RuntimeException re) {
      System.out.println(re);
    }

    try {
      v[2] = 2;
      System.out.println("ok");
    } catch(RuntimeException re) {
      System.out.println(re);
    }
  }
}
