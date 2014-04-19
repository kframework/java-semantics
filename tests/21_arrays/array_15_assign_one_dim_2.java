/*
Assign among arrays.
  - two one dim arrays, both initialized, assign one to another.
    Initialization value of assigned array is rewritten.
*/

public class array_15_assign_one_dim_2 {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    int[] v1 = new int[3], v2 = new int[1], v3;
    v1[0] = -1;
    v2[0] = 10;
    v3 = v2;
    v2 = v1;
    System.out.println(v2[0]);
    System.out.println(v3[0]);
  }
}
