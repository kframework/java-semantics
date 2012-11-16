/*
Default value of primitive types:
  byte[], short[], int[], long[], char[], boolean[].
*/

public class array_42_default_val_primitive {

  public static void main(String[] args) {
    byte[] vb = new byte[2];
    System.out.println(vb[0] + " " + vb[1]);

    short[] vs = new short[2];
    System.out.println(vs[0] + " " + vs[1]);

    int[] vi = new int[2];
    System.out.println(vi[0] + " " + vi[1]);

    long[] vl = new long[2];
    System.out.println(vl[0] + " " + vl[1]);

    char[] vc = new char[2];
    System.out.println(vc[0] + " " + vc[1]);

    boolean[] vbool = new boolean[2];
    System.out.println(vbool[0] + " " + vbool[1]);

    System.out.println("Done!");
  }
}

