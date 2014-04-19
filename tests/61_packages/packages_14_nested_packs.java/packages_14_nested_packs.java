/*
Nested packages. Packages pack, pack.p1, pack.p2, pack.p1.p11 A different class in each package,
  with the same name. Test all of them through fully-qualified class name from main.
*/

public class packages_14_nested_packs {
  public static void main(String[] args) {
    System.out.println(new pack.A() + " " + new pack.p1.A() + " "
      + new pack.p2.A() + " " + new pack.p1.p11.A());
    System.out.println("Done!");
  }
}
