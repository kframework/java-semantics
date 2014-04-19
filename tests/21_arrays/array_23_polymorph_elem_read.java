/*
Polymorphic array assignment, element read.
  NPE[] va; init a.
  RE[] vb = va; read vb.
*/

public class array_23_polymorph_elem_read {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    NullPointerException[] vnpe = new NullPointerException[2];
    vnpe[0] = null;
    vnpe[1] = new NullPointerException("npe");

    RuntimeException[] vre = vnpe;
    printArray(vre);

    RuntimeException[] vre2 = new RuntimeException[1];
    vre2[0] = new NullPointerException("npe2");

    Object[] ovre = vre2;
    System.out.println("ovre[0] = " + ovre[0]);
  }

  void printArray(RuntimeException[] v1) {
    for(int i=0; i<v1.length; i++) {
      System.out.print(v1[i] + " ");
    }
    System.out.println();
  }
}
