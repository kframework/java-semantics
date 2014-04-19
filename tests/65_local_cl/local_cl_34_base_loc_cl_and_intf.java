/*
Local class LB extending another local class and implementing a global interface.
  Testing polymorphism through casting the object to the class and to the interface and calling a relevant method.
*/

public class local_cl_34_base_loc_cl_and_intf {
  public static void main(String[] args) {
    new O(10).testLB();
    System.out.println("Done!");
  }
}

interface I {
  String f();
}

class O {

  int v;

  O(int v) {
    this.v = v;
  }

  void testLB() {

    class LA {

      int a,b;

      LA(int a, int b) {
        this.a = a;
        this.b = b;
        System.out.println("O1.LA.LA()");
      }

      public String g() {
        return "O.LA.g: v=" + v + ", a=" + a + ", b=" + b;
      }
    }

    class LB extends LA implements I {

      LB(O o, int a, int b) {
        o.super(a,b);
      }

      public String g() {
        return "O.LB.g[v = "+v+"]: " + super.g();
      }

      public String f() {
        return "O.LB.f[v = "+v+"]";
      }
    }

    LA la = new LB(new O(20), 3,4);
    System.out.println(la.g());

    I i = (I) la;
    System.out.println(i.f());
  }
}
