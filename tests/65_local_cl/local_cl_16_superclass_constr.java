/*
Local class LB caling a superclass constructor with parameters.
*/

public class local_cl_16_superclass_constr {
  public static void main(String[] args) {
    A a = new A(10);
    System.out.println(a.f());
    a = new O().createLB(1);
    System.out.println(a.f());
    a = new O().createLB(2);
    System.out.println(a.f());
    System.out.println("Done!");
  }
}

class A {

  int av;

  A(int av) {
    this.av = av;
  }

  String f() {
    return "A.f()[av="+av+"]";
  }
}

class O {

  A createLB(int paramv) {
    class LB extends A {
      LB(int v) {
        super(v);
      }

      String f() {return "O.container().f():" + super.f();}
    }

    return new LB(paramv);
  }
}
