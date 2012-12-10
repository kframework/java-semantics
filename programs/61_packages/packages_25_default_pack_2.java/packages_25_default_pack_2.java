/*
Main and two classes A and B are in the default package. The same classes are in the package pack.
  Test the classes from package pack, by simple name, from another class in pack.
*/

public class packages_25_default_pack_2 {
  public static void main(String[] args) {
    new pack.Test();
    System.out.println("Done!");
  }
}
