/*
33. Multi args, multi applicable, conversion.
  - decl: (short, short), (int, short), (short, int), (long, long),
  - decl: (Object, Object), (Object, RE)
  - call: (byte, byte), (int, byte), (byte, int), (int, int), (byte, long), (long, short)
  - call: (Object, Object), (RE, Object), (Object, RE), (RE, RE)
*/

public class overload_33_multi_appl_multi_arg {

  public static void main(String[] args) {
    A a = new A();
    Object o = null;
    RuntimeException re = null;

    a.f((byte) 0, (byte) 0);
    a.f((int)  0, (byte) 0);
    a.f((byte) 0, (int)  0);
    a.f((int)  0, (int)  0);
    a.f((byte) 0, (long) 0);
    a.f((long) 0, (short)0);
    a.f(o, o);
    a.f(re, o);
    a.f(o, re);
    a.f(re, re);

    System.out.println("Done!");
  }
}

class A {

  void f(short a, short b) {
    System.out.println("A.f(short, short)");
  }

  void f(int a, short b) {
    System.out.println("A.f(int, short)");
  }

  void f(short a, int b) {
    System.out.println("A.f(short, int)");
  }

  void f(long a, long b) {
    System.out.println("A.f(long, long)");
  }

  void f(Object a, Object b) {
    System.out.println("A.f(Object, Object)");
  }

  void f(Object a, RuntimeException b) {
    System.out.println("A.f(Object, RuntimeException)");
  }
}


