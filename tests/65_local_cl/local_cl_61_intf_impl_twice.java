/*
Inside the same method, two local classes implementing I. I have method f().
  Call the test on both of them, using the same local var, and observe the difference.
*/

public class local_cl_61_intf_impl_twice {
  public static void main(String[] args) {
    O o = new O();
    o.testLocals(1);
    o.testLocals(2);
    System.out.println("Done!");
  }
}

interface I1 {
  String f();
}

class O {

  void testLocals(int paramv) {
    class Local1 implements I1 {
      int v;

      Local1(int v) {
        this.v = v;
      }

      int getV() {return v;}

      public String f() {return "O.testLB().Local1.f()[v="+getV()+"]";}
    }

    class Local2 implements I1 {
      int v;

      Local2(int v) {
        this.v = v;
      }

      int getV() {return v;}

      public String f() {return "O.testLB().Local2.f()[v="+getV()+"]";}
    }

    Local1 local1 =  new Local1(paramv);
    Local2 local2 =  new Local2(paramv);
    System.out.println(local1.f());
    System.out.println(local2.f());
  }
}
