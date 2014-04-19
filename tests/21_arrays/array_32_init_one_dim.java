/*
One dim int[] = new int[]{1,3,7}
*/

public class array_32_init_one_dim {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    int[] v;
    v = new int[]{1,3,7};
    printArray(v);
  }

  void printArray(int[] v1) {
    for(int i=0; i<v1.length; i++) {
      System.out.print(v1[i] + " ");
    }
    System.out.println();
  }
}
