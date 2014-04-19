/*
17. Local class and hiding.
  - Class O, members: av, af(), bv, bf(), test(),
  - Class O.test().LA, members: av, af(), test().
  From LA.test() call av, af(), bv, bf(), this.av(, this.af(), LA.this.av, LA.this.af(), O.this.av, O.this.af().
*/

public class local_cl_17_hiding {
  public static void main(String[] args) {
    new O().test();
    System.out.println("Done!");
  }
}

class O {

  String av = "O.av";

  String af() {return "O.af()";}

  String bv = "O.bv";

  String bf() {return "O.bf()";}

  void test() {

    class LA {

      String av = "LA.av";

      String af() {return "LA.af()";}

      void test() {
        System.out.println("O.LA.test()[\n"
            +"av="+av+", af() = "+ af() + ",\n"
            +"bv="+bv+", bf() = "+ bf() + ",\n"
            +"this.av = "+ this.av +", this.af() = "+ this.af() + ",\n"
            +"LA.this.av = "+ LA.this.av +", LA.this.af() = "+ LA.this.af() + ",\n"
            +"O.this.av = "+ O.this.av +", O.this.af() = "+ O.this.af() + "\n"
            +"]");
      }
    }

    new LA().test();
  }
}
