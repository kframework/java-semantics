/*
Polymorphic array assignment.
  NPE[] va; init a.
  RE[] vb = va.
  va == vb?
*/

public class array_22_polymorph_array_assign {

  public static void main(String[] args) {
    new main();
    System.out.println("Done!");
  }
}

class main {
  main() {
    NullPointerException[] vnpe = new NullPointerException[2];
    vnpe[0] = null;
    vnpe[1] = new NullPointerException("npe");

    RuntimeException[] vre = vnpe;
    System.out.println(vnpe == vre);

    RuntimeException[] vre2 = new RuntimeException[1];
    vre2[0] = new NullPointerException("npe2");

    Object[] ovre = vre2;
    System.out.println(ovre == vre2);
  }
}
