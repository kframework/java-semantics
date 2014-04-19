/*
Compatibility of Object and int[].
    Object[] vo = new int[][]; Elem read,write.
*/

public class array_26_polymorph_obj_array {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    Object[] vo = new int[3][];
    vo[0] = new int[5];
    System.out.println(vo[0].getClass().getName());
  }
}
