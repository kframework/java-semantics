/*
Class initialization conditions.
Class A static field write.
*/

public class static_i_trig_105_static_f_write {
  public static void main(String[] args) {
    A.a = 7;
    A.a = 8;
    System.out.println("Done!");
  }
}

class A {

  static {
    System.out.println("A.(static init)");
  }

  static int a = trace(1);

  static int trace(int a) {
    System.out.println("trace(" + a + ")");
    return a;
  }
}
