/*
Default value of refs:
  Object[], String[], RuntimeException[], Object[][], int[][].
*/

public class array_43_default_val_ref {

  public static void main(String[] args) {
    Object[] vo = new Object[2];
    System.out.println(vo[0] + " " + vo[1]);

    String[] vs = new String[2];
    System.out.println(vs[0] + " " + vs[1]);

    RuntimeException[] vre = new RuntimeException[2];
    System.out.println(vre[0] + " " + vre[1]);

    Object[][] vvo = new Object[2][];
    System.out.println(vvo[0] + " " + vvo[1]);

    int[][] vvi = new int[2][];
    System.out.println(vvi[0] + " " + vvi[1]);

    System.out.println("Done!");
  }
}

