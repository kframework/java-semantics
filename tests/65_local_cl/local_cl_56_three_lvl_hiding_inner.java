/*
Local class, inside instance method, inside another inner class,
  inside a top-level class. Class members:
  - O: af(), av, bf(), bv, cf(), cv.
  - Mid: af(), av, bf(), bv, test()
  - ILB: af(), av, test().
  All members are non-static.
  Access them by simple name from ILB.test(). Also discriminate using this, O.this, Mid.this, ILB.this.
  See $8.1.3 for the precise semantics of inner classes.
*/

public class local_cl_56_three_lvl_hiding_inner {
  public static void main(String[] args) {
    new O().new Mid().test();
    System.out.println("Done!");
  }
}

class O {

  String av = "O.av";

  String af() {return "O.af()";}

  String bv = "O.bv";

  String bf() {return "O.bf()";}

  String cv = "O.cv";

  String cf() {return "O.cf()";}

  class Mid {

    String av = "Mid.av";

    String af() {return "Mid.af()";}

    String bv = "Mid.bv";

    String bf() {return "Mid.bf()";}

    void test() {
      class ILB {

        String av = "ILB.av";

        String af() {return "ILB.af()";}

        void test() {
          System.out.println("O.Mid.test().ILB.test()[\n"
              +"av="+av+", af() = "+ af() + ",\n"
              +"bv="+bv+", bf() = "+ bf() + ",\n"
              +"cv="+cv+", cf() = "+ cf() + ",\n"
              +"this.av = "+ this.av +", this.af() = "+ this.af() + ",\n"
              +"ILB.this.av = "+ ILB.this.av +", ILB.this.af() = "+ ILB.this.af() + ",\n"
              +"Mid.this.av = "+ Mid.this.av +", Mid.this.af() = "+ Mid.this.af() + ",\n"
              +"O.this.av = "+ O.this.av +", O.this.af() = "+ O.this.af() + "\n"
              +"]");
        }
      }

      new ILB().test();
    }
  }
}
