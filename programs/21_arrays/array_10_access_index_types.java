/*
Various index types: int, short, byte, char (true literal).
*/

public class array_10_access_index_types {

  public static void main(String[] args) {
    new main();
    System.out.println();
    System.out.println("Done!");
  }
}

class main {
  main() {
    String[] v = new String['x' + 1];

    v[3] = "int";
    System.out.println(v[3]);

    v[(short)4] = "short";
    System.out.println(v[(short)4]);

    v[(byte)5] = "byte";
    System.out.println((byte)5);

    v['x'] = "char";
    System.out.println(v['x']);
  }
}
