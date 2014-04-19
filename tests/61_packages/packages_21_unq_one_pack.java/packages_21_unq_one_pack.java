/*
Two classes pack.A and pack.B in the same compilation unit.
  Test both from pack.Test (separate CU), by simple name.
*/

public class packages_21_unq_one_pack {
  public static void main(String[] args) {
    new pack.Test();
    System.out.println("Done!");
  }
}
