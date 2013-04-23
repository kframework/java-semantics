/*
Inner array type:
  m = new Object[][]{ {new RuntimeException("re")} }
  (RuntimeException[])m[0] - throws ClassCastException
*/

public class array_sep_37_init_inner_array_type {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    Object[][] m;
    m = new Object[][]{ {new RuntimeException("re")} };
    if (m[0] instanceof RuntimeException[]) {
      System.out.println("Inner array is of type RuntimeException[]");
    } else {
      System.out.println("Inner array is of type Object[]");
    }
  }
}
