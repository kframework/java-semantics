/*
Single type import.
  Classes Main, pt.Test, p.pb.A, p.pc.A. Import p.pb.A from Main and p.pc.A
  from pd.Test. Test the simple name "A" from the classes Main and Test.
*/

import p.pb.A;

public class packages_32_single_t_imp_typical {
  public static void main(String[] args) {
    System.out.println("main   : A = " + new A());
    System.out.println("pt.Test: A = " + new pt.Test().createA());
    System.out.println("Done!");
  }
}
