/*
Assign among arrays.
  - two one dim arrays, assign one to another. Test an element in the second array.
  Change an element in the first. Element should be changed in both arrays.
*/

public class array_sep_14_assign_one_dim_1 {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    int[] v1, v2;
    v1 = new int[3];
    v1[2] = 22;
    v2 = v1;
    System.out.println(v2[2]);
    v1[2] = 23;
    System.out.println(v2[2]);
    System.out.println(v1 == v2);
  }
}
