/*
A local class LB that overwrites a method test() in the base class A. Also have an own method and field,
  accessed by test().
*/

public class local_cl_13_own_members {
  public static void main(String[] args) {
    A a = new A();
    System.out.println(a.f());
    a = new O().createLB(1);
    System.out.println(a.f());
    a = new O().createLB(2);
    System.out.println(a.f());
    System.out.println("Done!");
  }
}

class A {
  String f() {
    return "A.f()";
  }
}

class O {

  A createLB(int paramv) {
    class LB extends A {
      int v;

      LB(int v) {
        this.v = v;
      }

      int getV() {return v;}

      String f() {return "O.container().f()[v="+getV()+"]";}
    }

    return new LB(paramv);
  }
}
