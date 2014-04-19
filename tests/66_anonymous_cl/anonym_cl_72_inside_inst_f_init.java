/*
Anonymous class implementing an interface as instance field initializer. Access other instance and static fields.
*/

public class anonym_cl_72_inside_inst_f_init {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

interface I1 {
  void test();
}

class O {

  int v = 1;

  static int sv = 1;

  String f() {
    return "anon.f()";
  }

  I1 i1 = new I1() {
    public void test() {
      System.out.println("anon: v = "+ v + ", sv = "+ sv + ", f() = " + f());
    }
  };

  void test() {
    i1.test();
  }
}
