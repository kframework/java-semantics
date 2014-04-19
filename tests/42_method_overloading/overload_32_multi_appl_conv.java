/*
32. One arg, multi applicable, conversion
  - decl: arg types: short, long, Object, Object[]
  - call: byte, short, char, int, long, Object, RuntieException, Object[], Object[][].
*/

public class overload_32_multi_appl_conv {

  public static void main(String[] args) {
    A a = new A();

    a.f((byte)0);
    a.f((short)0);
    a.f('i');
    a.f(0);
    a.f(0L);
    a.f(new Object());
    a.f(new RuntimeException(""));
    a.f(new Object[2]);
    a.f(new Object[2][]);

    System.out.println("Done!");
  }
}

class A {

  void f(short a) {
    System.out.println("A.f(short)");
  }

  void f(long a) {
    System.out.println("A.f(long)");
  }

  void f(Object a) {
    System.out.println("A.f(Object)");
  }

  void f(Object[] a) {
    System.out.println("A.f(Object[])");
  }
}


