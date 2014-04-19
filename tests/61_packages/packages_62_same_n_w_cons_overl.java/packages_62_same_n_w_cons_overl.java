/*
Class name collision in hierarchy, three-level hierarchy.
  p2.B < p2.A < p1.A. Constructors:
  - p2.B(), calls super(byte)
  - p2.A(int)
  - p1.A(short)
  Constructors are traced. Instantiate new p2.B().
*/

public class packages_62_same_n_w_cons_overl {

  public static void main(String[] args) {
    new p2.B();
    System.out.println("Done!");
  }
}

