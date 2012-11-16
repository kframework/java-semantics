/*
Left-to-right eval: {i++,i++,i++}
*/

public class array_35_init_seqstrict {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    int i = 0;
    int[] v;
    v = new int[]{i++,i++,i++};
    printArray(v);
  }

  void printArray(int[] v1) {
    if (v1 == null) {
      System.out.println(v1);
    } else {
      for(int i=0; i<v1.length; i++) {
        System.out.print(v1[i] + " ");
      }
      System.out.println();
    }
  }
}
