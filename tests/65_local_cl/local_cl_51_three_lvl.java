/*
Local class inside an inner class inside a top-level class. Accessing fields and methods of inner
  and top-level by simple name.
*/

public class local_cl_51_three_lvl {
  public static void main(String[] args) {
    I1 i1;
    i1 = new O(1).new Mid().createLB();
    System.out.println(i1.f());
    i1 = new O(2).new Mid().createLB();
    System.out.println(i1.f());
    System.out.println("Done!");
  }
}

interface I1 {
  String f();
}

class O {

  String ov = "O.ov";

  String of() {return "O.of()";}

  O(int param) {
    ov += "[" + param + "]";
  }

  class Mid {

    String mv = "Mid.mv";

    String mf() {return "Mid.mf()";}

    I1 createLB() {
      class LB implements I1 {

        public String f() {
          return "O.createLB().f()[ov="+ov+", of() = "+ of() +", mv = "+ mv + ", mf() = "+ mf() +"]";
        }
      }

      return new LB();
    }
  }
}
