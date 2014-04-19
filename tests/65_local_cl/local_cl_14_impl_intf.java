/*
A local class LB implementing an interface with method test(). Also have an own method and field,
  accessed by test().
*/

public class local_cl_14_impl_intf {
  public static void main(String[] args) {
    I1 i1 = new O().createLB(1);
    System.out.println(i1.f());
    i1 = new O().createLB(2);
    System.out.println(i1.f());
    System.out.println("Done!");
  }
}

interface I1 {
  String f();
}

class O {

  I1 createLB(int paramv) {
    class LB implements I1 {
      int v;

      LB(int v) {
        this.v = v;
      }

      int getV() {return v;}

      public String f() {return "O.container().f()[v="+getV()+"]";}
    }

    return new LB(paramv);
  }
}
