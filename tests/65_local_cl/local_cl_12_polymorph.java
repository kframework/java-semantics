/*
A local class LB that overwrites a method of the base class A.
*/

public class local_cl_12_polymorph {
  public static void main(String[] args) {
    A a = new A();
    System.out.println(a.f());
    a = new O().createLB();
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

  A createLB() {
    class LB extends A {
      String f() {return "O.container().f()";}
    }

    return new LB();
  }
}
