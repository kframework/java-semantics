/*
ArrayIndexOutOfBoundsException.
  - one dim, negative, read & write.
  - one dim, = length
  - one dim > length
  - one dim = 0, index = 0.
  - two dims, second dim negative
  - two dims, second dim = length
  - two dims, second dim > length
*/

public class array_sep_11_access_AOOBException {

  public static void main(String[] args) {
    new main();
    System.out.println();
    System.out.println("Done!");
  }
}

class main {
  main() {
    int[] v = new int[2];

    try {
      v[0] = v[-2];
      System.out.println("ok");
    } catch(RuntimeException re) {
      System.out.println(re);
    }

    try {
      v[-2] = -2;
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

    try {
      v[3] = 2;
      System.out.println("ok");
    } catch(RuntimeException re) {
      System.out.println(re);
    }

    v = new int[0];
    try {
      v[0] = 0;
      System.out.println("ok");
    } catch(RuntimeException re) {
      System.out.println(re);
    }

    int[][] m = new int[3][3];

    try {
      m[2][-1] = 2;
      System.out.println("ok");
    } catch(RuntimeException re) {
      System.out.println(re);
    }

    try {
      m[2][3] = 2;
      System.out.println("ok");
    } catch(RuntimeException re) {
      System.out.println(re);
    }

    try {
      m[2][15] = 2;
      System.out.println("ok");
    } catch(RuntimeException re) {
      System.out.println(re);
    }
  }
}
