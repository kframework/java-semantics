/*
Method Overloading through multiple interface inheritance.
  A < (I3, I4). I3 < (I1, I2). I4 < I1.
  Each class and interface have a specific version of f(). Test all cases.
*/

public class interface_36_multi_i_overload {
  public static void main(String[] args) {
    System.out.println("Target var I1:");
    I1 i1 = new A();
    i1.f((byte)0);
    i1.f((short)0);
    i1.f((int)0);
    i1.f((long)0);
    i1.f((char)0);

    System.out.println("\nTarget var I2:");
    I2 i2 = (I2)i1;
    i2.f((byte)0);
    i2.f((short)0);
    i2.f((int)0);
    i2.f((char)0);

    System.out.println("\nTarget var I3:");
    I3 i3 = (I3)i1;
    i3.f((byte)0);
    i3.f((short)0);
    i3.f((int)0);
    i3.f((long)0);
    i3.f((char)0);

    System.out.println("\nTarget var I4:");
    I4 i4 = (I4)i1;
    i4.f((byte)0);
    i4.f((short)0);
    i4.f((int)0);
    i4.f((long)0);
    i4.f((char)0);

    System.out.println("\nTarget var A:");
    A a = (A)i1;
    a.f((byte)0);
    a.f((short)0);
    a.f((int)0);
    a.f((long)0);
    a.f((char)0);

    System.out.println("Done!");
  }
}

interface I1 {
  void q();
  void f(long a);
}

interface I2 {
  void f(int a);
}

interface I3 extends I1, I2 {
  void f(byte a);
}

interface I4 extends I1 {
  void f(short a);
}

class A implements I3, I4 {
  public void q() {
    System.out.println("A.q()");
  }

  public void f(long a) {
    System.out.println("A.f(long)");
  }

  public void f(int a) {
    System.out.println("A.f(int)");
  }

  public void f(short a) {
    System.out.println("A.f(short)");
  }

  public void f(byte a) {
    System.out.println("A.f(byte)");
  }

  public void f(char a) {
    System.out.println("A.f(char)");
  }
}


