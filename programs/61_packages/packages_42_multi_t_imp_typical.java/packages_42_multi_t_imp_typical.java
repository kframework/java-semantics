/*
Type import on demand.
  Classes Main, pt.Test, p1.A, p1.B, p2.A, p2.B Import p1.* from Main and p2.* from pt.Test.
  Test the simple names A and B from the classes Main and pt.Test.
*/

import p1.*;
import pt.Test;

public class packages_42_multi_t_imp_typical {
  public static void main(String[] args) {
    System.out.println("main   : A = " + new A());
    System.out.println("main   : B = " + new B());
    Test test = new Test();
    System.out.println("pt.Test: A = " + test.createA());
    System.out.println("pt.Test: B = " + test.createB());
    System.out.println("Done!");
  }
}
