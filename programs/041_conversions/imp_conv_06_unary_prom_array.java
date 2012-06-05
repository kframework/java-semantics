/*
Unary promotion: array cration, array access.
*/
public class imp_conv_06_unary_prom_array {
  public static void main(String[] args) {
    byte n = 10;
    byte i = 5;
    int[] v = new int[n];
    v[i] = 200;
    System.out.println(v[i]);
    System.out.println("Done!");
  }
}

