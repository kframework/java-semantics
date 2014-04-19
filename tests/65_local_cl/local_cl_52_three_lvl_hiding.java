/*
Local class inside an inner class inside a top-level class. Field and method with the same name
  in Outer, Mid and Local. Discriminate among them using this, Mid.this, Outer.this.
*/

public class local_cl_52_three_lvl_hiding {
  public static void main(String[] args) {
    I1 i1;
    i1 = new O(1).new Mid().createLB();
    System.out.println(i1.test());
    i1 = new O(2).new Mid().createLB();
    System.out.println(i1.test());
    System.out.println("Done!");
  }
}

interface I1 {
  String test();
}

class O {

  String v = "O.v";

  String f() {return "O.f()";}

  O(int param) {
    v += "[" + param + "]";
  }

  class Mid {

    String v = "Mid.v";

    String f() {return "Mid.f()";}

    I1 createLB() {
      class LB implements I1 {

        String v = "LB.v";

        String f() {return "LB.f()";}

        public String test() {
          return "O.createLB().test()["
              +"v="+v+", f() = "+ f()
              +", this.v = "+ this.v + ", this.f() = "+ this.f()
              +", Mid.this.v = "+ Mid.this.v + ", Mid.this.f() = "+ Mid.this.f()
              +", O.this.v = "+ O.this.v + ", O.this.f() = "+ O.this.f()
              +"]";
        }
      }

      return new LB();
    }
  }
}
