/*
Type import on demand in a compilation unit with multiple classes.
  Classes Main, Test in the same CU, pt.Test1, pt.Test2 in the same CU.
  Also classes pa1.A, pa2.A. Import pa1.* from CU Main and pa2.* from pd.Test1.
  Test simple name A from Main and the three test classes.
*/

import pa1.*;
import pt.Test1;

public class packages_44_multi_t_imp_same_cu {
  public static void main(String[] args) {
    System.out.println("main   : A = " + new A());
    System.out.println("Test   : B = " + new Test().createA());
    Test1 test1 = new Test1();
    System.out.println("pt.Test1: A = " + test1.createA());
    System.out.println("pt.Test2: A = " + test1.test2CreateA());
    System.out.println("Done!");
  }
}

class Test {
  public A createA() {
    return new A();
  }
}
