/*
Type import on demand, nested packages.
  Classes Main, pt.Test, p1.A, p1.B, p.p1.A, p.p1.B, Import p.p1.* from Main and p1.* from pt.Test.
  Test the simple names A and B from the classes Main and pt.Test.
*/

import p.p1.*;

public class packages_47_multi_t_imp_nested_p {
  public static void main(String[] args) {
    System.out.println("main   : A = " + new A());
    System.out.println("main   : B = " + new B());
    pt.Test test = new pt.Test();
    System.out.println("pt.Test: A = " + test.createA());
    System.out.println("pt.Test: B = " + test.createB());
    System.out.println("Done!");
  }
}
