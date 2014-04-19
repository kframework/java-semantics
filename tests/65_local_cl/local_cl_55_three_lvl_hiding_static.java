/*
Local class, inside static method, inside a static inner class,
  inside a top-level class. Class members:
  - O: af(), av, bf(), bv, cf(), cv, test().
  - Mid: af(), av, bf(), bv, test()
  - ILB: af(), av, test().
  All members are static, exept those of ILB.
  Since all local classes are inner classes, they cannot have static methods.
  Access them by simple name from ILB.test(). Also discriminate using class qualifier.
*/

public class local_cl_55_three_lvl_hiding_static {
  public static void main(String[] args) {
    System.out.println(O.Mid.test());
    System.out.println("Done!");
  }
}

class O {

  static String av = "O.av";

  static String af() {return "O.af()";}

  static String bv = "O.bv";

  static String bf() {return "O.bf()";}

  static String cv = "O.cv";

  static String cf() {return "O.cf()";}

  static class Mid {

    static String av = "Mid.av";

    static String af() {return "Mid.af()";}

    static String bv = "Mid.bv";

    static String bf() {return "Mid.bf()";}

    static String test() {
      class ILB {

        String av = "ILB.av";

        String af() {return "ILB.af()";}

        public String test() {
          return "O.Mid.test().ILB.test()[\n"
              +"av="+av+", af() = "+ af() + ",\n"
              +"bv="+bv+", bf() = "+ bf() + ",\n"
              +"cv="+cv+", cf() = "+ cf() + ",\n"
              +"Mid.av = "+ Mid.av +", Mid.af() = "+ Mid.af() + ",\n"
              +"O.av = "+ O.av +", O.af() = "+ O.af() + "\n"
              +"]";
        }
      }

      return new ILB().test();
    }
  }
}
