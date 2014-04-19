/*
Two simple packages pack1 and pack2. One class inside each, with different names. Refer both
  through fully-qualified class name.
*/

public class packages_12_two_packs {
  public static void main(String[] args) {
    System.out.println(new pack1.A() + " " + new pack2.B());
    System.out.println("Done!");
  }
}
