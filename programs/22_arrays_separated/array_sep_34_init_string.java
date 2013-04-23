/*
One dim string = new String[]{"abc", "d"+"e"}
*/

public class array_sep_34_init_string {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    String[] v;
    v = new String[]{"abc", "d"+"e"};
    printArray(v);
  }

  void printArray(String[] v1) {
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
