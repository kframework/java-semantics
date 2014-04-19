/*
Single type import in a compilation unit with multiple classes.
  Classes Main, Test in the same CU, pt.Test1, pt.Test2 in the same CU.
  Also classes p.pb.A, p.pc.A. Import p.pb.A from CU (Main,Test) and p.pc.A from pt.(Test1,Test2).
  Test simple name A from Main and the three test classes.
*/

import p.pb.A;

public class packages_34_single_t_imp_same_cu {
  public static void main(String[] args) {
    System.out.println("main     : A = " + new A());
    System.out.println("Test     : A = " + new Test().createA());
    System.out.println("pt.Test1 : A = " + new pt.Test1().createA());
    System.out.println("pt.Test2 : A = " + new pt.Test1().createTest2A());
    System.out.println("Done!");
  }
}

class Test {
  public A createA() {
    return new A();
  }
}
