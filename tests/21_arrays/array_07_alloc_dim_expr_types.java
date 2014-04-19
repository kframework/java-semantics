/*
Various dim expression types: int, short, byte, char (true literal).
  For each a read and a write.
*/

public class array_07_alloc_dim_expr_types {

  public static void main(String[] args) {
    new main();
    System.out.println();
    System.out.println("Done!");
  }
}

class main {
  main() {
    String[] v;

    v = new String[2];
    v[1] = "int";
    System.out.println(v[1]);

    v = new String[(short)2];
    v[1] = "short";
    System.out.println(v[1]);

    v = new String[(byte)2];
    v[1] = "byte";
    System.out.println(v[1]);

    v = new String['x'];
    v[1] = "char";
    System.out.println(v[1]);
  }
}
