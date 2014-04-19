/*
31. One arg, multi applicable, no conversion.
  - decl: f(byte), f(short), f(char), f(int), f(long), f(Object), f(RE)
  - call with all types
*/

public class overload_31_multi_appl {

  public static void main(String[] args) {
    A a = new A();

    a.f((byte)0);
    a.f((short)0);
    a.f('i');
    a.f(0);
    a.f(0L);
    a.f(new Object());
    a.f(new RuntimeException(""));

    System.out.println("Done!");
  }
}

class A {
  void f(byte a) {
    System.out.println("A.f(byte)");
  }

  void f(short a) {
    System.out.println("A.f(short)");
  }

  void f(char a) {
    System.out.println("A.f(char)");
  }

  void f(int a) {
    System.out.println("A.f(int)");
  }

  void f(long a) {
    System.out.println("A.f(long)");
  }

  void f(Object a) {
    System.out.println("A.f(Object)");
  }

  void f(RuntimeException a) {
    System.out.println("A.f(RuntimeException)");
  }
}


