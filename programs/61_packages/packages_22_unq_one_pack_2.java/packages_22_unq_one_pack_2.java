/*
Two classes pack.A and pack.B in different compilation units.
  Test both from pack.Test (separate CU), by simple name.
*/

public class packages_22_unq_one_pack_2 {
  public static void main(String[] args) {
    new pack.Test();
    System.out.println("Done!");
  }
}
