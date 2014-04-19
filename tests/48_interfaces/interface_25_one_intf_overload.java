/*
Interfaces and overloading.
  A < I1. two versions of f(...) in I1, third, the most specific one - in A.
*/

public class interface_25_one_intf_overload {
  public static void main(String[] args) {
    A a = new A();
    a.f((short)0);
    a.f((int)0);
    a.f((long)0);

    I1 i1 = (I1)a;
    i1.f((short)0);
    i1.f((int)0);
    i1.f((long)0);

    System.out.println("Done!");
  }
}

interface I1 {
  void f(int a);
  void f(long a);
}

class A implements I1 {
  public void f(int a) {
    System.out.println("A.f(int)");
  }

  public void f(long a) {
    System.out.println("A.f(long)");
  }

  public void f(short a) {
    System.out.println("A.f(short)");
  }
}


