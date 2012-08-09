/*
7. Array variable, [] as part of the declarator (compatibility with C):
  - int[] b[]. Assign, access.
*/

public class array_07_decl_C_style {

  public static void main(String[] args) {
    new main();
    System.out.println("\n"+ "Done!");
  }
}

class main {
  main() {
    int[] m[];
    m = new int[2][2];

    m[0][0] = 44;
    System.out.println(m[0][0]);
  }
}
