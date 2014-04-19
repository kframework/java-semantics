/*
Class initialization conditions.
Class A static field read.
*/

public class static_i_trig_104_static_f_read {
  public static void main(String[] args) {
    System.out.println(A.a + " " + A.a);
    System.out.println("Done!");
  }
}

class A {

  static {
    System.out.println("A.(static init)");
  }

  static int a = trace(1);

  static int trace(int a) {
    System.out.println("trace("+a+")");
    return a;
  }
}
