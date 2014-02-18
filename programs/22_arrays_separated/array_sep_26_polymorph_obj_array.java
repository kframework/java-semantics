/*
Compatibility of Object and int[].
    Object[] vo = new int[][]; Elem read,write.
    Also tests array access expressions where target array is a cast expression.
*/

public class array_sep_26_polymorph_obj_array {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    Object[] vo = new int[3][];
    int[] vi = new int[5];
    vi[0] = 10;
    vo[0] = vi;
    System.out.println(((int[])vo[0])[0]);
  }
}
