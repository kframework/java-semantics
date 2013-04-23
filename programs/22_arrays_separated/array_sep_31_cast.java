/*
Array cast.
  - cast ok: RuntimeException[] -> NPE[], object is NPE[]
    Print content after cast.
  - ClassCastException: RuntimeException[] -> NPE[], object is RuntimeException[].
*/

public class array_sep_31_cast {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    RuntimeException[] vre = new NullPointerException[2];
    vre[0] = null;
    vre[1] = new NullPointerException();

    try {
      NullPointerException[] vnpe = (NullPointerException[]) vre;
      printArray(vnpe, 2);
    } catch (ClassCastException e) {
      System.out.println(e);
    }

    vre = new RuntimeException[0];
    try {
      NullPointerException[] vnpe = (NullPointerException[]) vre;
      printArray(vnpe, 0);
    } catch (ClassCastException e) {
      System.out.println(e);
    }
  }

  void printArray(NullPointerException[] v1, int len) {
    for(int i=0; i<len; i++) {
      System.out.print(v1[i] + " ");
    }
    System.out.println();
  }
}
