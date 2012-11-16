/*
Array allocation by new, value assignment and value read:
  - int
  - short
  - String
  - Object
  - RuntimeException
*/

public class array_01_overview {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    int[] vi = new int[2];
    for(int i=0; i< 2; i++) {
      vi[i] = i;
      System.out.println(vi[i]);
    }

    short[] vsh = new short[3];
    for(int i=0; i < 3; i++) {
      vsh[i] = (short)i;
      System.out.println(vsh[i]);
    }

    String[] vs = new String[4];
    for(int i=0; i< 4; i++) {
      vs[i] = "s" + i;
      System.out.println(vs[i]);
    }

    Object[] vo = new Object[2];
    for(int i=0; i< 2; i++) {
      vo[i] = new Object();
      System.out.println(vo[i] != null);
    }

    RuntimeException[] vre = new RuntimeException[2];
    for(int i=0; i< 2; i++) {
      vre[i] = new RuntimeException("re" + i);
      System.out.println(vre[i]);
    }
  }
}
