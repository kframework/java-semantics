/*
Polimorphic array assignment, element read and element write.
  - RuntimeException[] vre = NullPointerException[]. assign. read.
  - O[] RE[0] = new NPE[] - assigning to array element a more derived type than
    aray object type. Permitted.
*/

public class array_24_polymorph_elem_write {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    RuntimeException[] vre = new NullPointerException[2];
    vre[0] = null;
    vre[1] = new NullPointerException("npe");
    printArray(vre);

    Object[] ovre = new RuntimeException[1];
    ovre[0] = new NullPointerException("npe2");
    System.out.println("ovre[0] = " + ovre[0]);
  }

  void printArray(RuntimeException[] v1) {
    for(int i=0; i<v1.length; i++) {
      System.out.print(v1[i] + " ");
    }
    System.out.println();
  }
}
