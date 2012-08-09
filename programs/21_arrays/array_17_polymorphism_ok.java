/*
17. Compatible arrays assignment.
  - RuntimeException[] vre = NullPointerException[]. assign. read.
*/

public class array_17_polymorphism_ok {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main() {
  main() {
    RuntimeException[] vre = new NullPointerException[2];
    vre[0] = null;
    vre[1] = new NullPointerException("npe");
    printArray(vre);
  }

  void printArray(RuntimeException[] v1) {
    for(int i=0; i<v1.length; i++) {
      System.out.print(v1[i] + " ");
    }
    System.out.println();
  }
}
