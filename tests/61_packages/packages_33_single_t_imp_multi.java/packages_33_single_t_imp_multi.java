/*
Multiple single-type imports.
  Classes Main, Test, p.pb.A, p.pb.B, p.pb.Test, p.pc.A, p.pc.B.
  From Main import p.pb.A and p.pc.B. From Test import p.pc.A and p.pb.B.
  Test the simple name "A" and "B" from the classes Main, Test and p.pb.Test.
*/

import p.pb.A;
import p.pc.B;

public class packages_33_single_t_imp_multi {
  public static void main(String[] args) {
    System.out.println("main     : A = " + new A());
    System.out.println("main     : B = " + new B());
    System.out.println("Test     : A = " + new Test().createA());
    System.out.println("Test     : B = " + new Test().createB());
    System.out.println("p.pb.Test: A = " + new p.pb.Test().createA());
    System.out.println("p.pb.Test: B = " + new p.pb.Test().createB());
    System.out.println("Done!");
  }
}
