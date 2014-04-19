/*
Local class LB accessing fields and methods of the enclosing class by simple name.
*/

public class local_cl_15_outer_members_acc {
  public static void main(String[] args) {
    I1 i1;
    i1 = new O(1).createLB();
    System.out.println(i1.f());
    i1 = new O(2).createLB();
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

  I1 createLB() {
    class LB implements I1 {

      public String f() {
        return "O.createLB().f()[ov="+ov+", of() = "+ of() +"]";
      }
    }

    return new LB();
  }
}
