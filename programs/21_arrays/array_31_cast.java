/*
Array cast.
  - cast ok: RuntimeException[] -> NPE[], object is NPE[]
    Print content after cast.
  - ClassCastException: RuntimeException[] -> NPE[], object is RuntimeException[].
*/

public class array_31_cast {

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

    try {
      NullPointerException[] vnpe = (NullPointerException[]) vre;
      printArray(vnpe);
    } catch (ClassCastException e) {
      System.out.println(e);
    }

    vre = new RuntimeException[0];
    try {
      NullPointerException[] vnpe = (NullPointerException[]) vre;
      printArray(vnpe);
    } catch (ClassCastException e) {
      System.out.println(e);
    }
  }

  void printArray(NullPointerException[] v1) {
    for(int i=0; i<v1.length; i++) {
      System.out.print(v1[i] + " ");
    }
    System.out.println();
  }
}
