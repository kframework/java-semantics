/*
Testing instantiation, static method access, static field read and static field write
  through a fully-qualified class name.
  Classes Main, p1.A. Class p1.A have a traced constructor, static method f() and static field v.
  Test new p1.A(), p1.A.f(), p1.A.a, p1.A.a = x from Main.
*/

public class packages_51_fullyqual_in_qualifiers {
  public static void main(String[] args) {
    new p1.A();
    p1.A.f();
    System.out.println("p1.A.v = " + p1.A.v);
    p1.A.v = 7;
    System.out.println("Executed p1.A.v = 7.");
    System.out.println("p1.A.v = " + p1.A.v);
    System.out.println("Done!");
  }
}
