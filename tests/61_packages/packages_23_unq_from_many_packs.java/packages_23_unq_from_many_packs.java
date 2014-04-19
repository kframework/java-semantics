/*
Packages pack, pack.pbb, pack.pcc. Each have a class A and Test. From each class Test
  check the simple name A and all the fully-qualified class names.
*/

public class packages_23_unq_from_many_packs {
  public static void main(String[] args) {
    new pack.Test();
    System.out.println();
    new pack.pbb.Test();
    System.out.println();
    new pack.pcc.Test();
    System.out.println("Done!");
  }
}
