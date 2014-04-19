/*
Multiple type imports on demand.
  Classes Main, pt.Test, pa1.A, pa2.A, pb1.B, pb1.C, pb2.B, pb2.C From Main import
  pa1.* and pb2.*. From pt.Test import pa2.* and pb1.*.
  Test the simple name "A", "B" and "C" from the classes Main and pt.Test. Also "C" from pt.Test.
*/

import pa1.*;
import pb2.*;
import pt.Test;

public class packages_43_multi_t_imp_multi {
  public static void main(String[] args) {
    System.out.println("main   : A = " + new A());
    System.out.println("main   : B = " + new B());
    System.out.println("main   : C = " + new C());
    Test test = new Test();
    System.out.println("pt.Test: A = " + test.createA());
    System.out.println("pt.Test: B = " + test.createB());
    System.out.println("pt.Test: C = " + test.createC());
    System.out.println("Done!");
  }
}
