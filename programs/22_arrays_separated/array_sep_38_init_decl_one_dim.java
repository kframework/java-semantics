/*
Array initializer as part of array var declaration:

One dim int[] = {1,3,7}
*/

public class array_sep_38_init_decl_one_dim {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    int[] v = {1,3,7};
    printArray(v);
  }

  void printArray(int[] v1) {
    for(int i=0; i<3; i++) {
      System.out.print(v1[i] + " ");
    }
    System.out.println();
  }
}
