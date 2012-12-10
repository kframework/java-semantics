/*
Main and two classes A and B are in the default package. The same classes are in the package pack.
  Test all four of them from Main.
*/

public class packages_24_default_pack {
  public static void main(String[] args) {
    System.out.println(new A() + " " + new B() + " " + new pack.A() + " " + new pack.B());
    System.out.println("Done!");
  }
}
