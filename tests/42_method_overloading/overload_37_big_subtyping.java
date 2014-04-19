/*
37. Extensive test of subtyping.
    - A: long, Object, boolean
    - B: int, char, String, Object[]
    - C: byte, short, RE[], int[], Object[][]
    - C < B < A
    - Call targets: A a, B b, C c.
    - call arguments: all primitive types, Object, String, RE, Object[], String[], RE[], int[], int[][], Object[][], RE[][]
*/

public class overload_37_big_subtyping {

  public static void main(String[] args) {
    A a = new A();
    B b = new B();
    C c = new C();

    a.f((byte)0);
    a.f((short)0);
    a.f((int)0);
    a.f((long)0);
    a.f((char)0);
    a.f(false);
    a.f((Object)null);
    a.f((String)null);
    a.f((RuntimeException)null);
    a.f((Object[])null);
    a.f((String[])null);
    a.f((RuntimeException[])null);
    a.f((int[])null);
    a.f((int[][])null);
    a.f((Object[][])null);
    a.f((RuntimeException[][])null);
    System.out.println();

    b.f((byte)0);
    b.f((short)0);
    b.f((int)0);
    b.f((long)0);
    b.f((char)0);
    b.f(false);
    b.f((Object)null);
    b.f((String)null);
    b.f((RuntimeException)null);
    b.f((Object[])null);
    b.f((String[])null);
    b.f((RuntimeException[])null);
    b.f((int[])null);
    b.f((int[][])null);
    b.f((Object[][])null);
    b.f((RuntimeException[][])null);
    System.out.println();

    c.f((byte)0);
    c.f((short)0);
    c.f((int)0);
    c.f((long)0);
    c.f((char)0);
    c.f(false);
    c.f((Object)null);
    c.f((String)null);
    c.f((RuntimeException)null);
    c.f((Object[])null);
    c.f((String[])null);
    c.f((RuntimeException[])null);
    c.f((int[])null);
    c.f((int[][])null);
    c.f((Object[][])null);
    c.f((RuntimeException[][])null);
    System.out.println();

    System.out.println("Done!");
  }
}

class A {

  void f(long a) {
    System.out.println("A.f(long)");
  }

  void f(Object a) {
    System.out.println("A.f(Object)");
  }

  void f(boolean a) {
    System.out.println("A.f(boolean)");
  }
}

class B extends A {

  void f(int a) {
    System.out.println("B.f(int)");
  }

  void f(char a) {
    System.out.println("B.f(char)");
  }

  void f(String a) {
    System.out.println("B.f(String)");
  }

  void f(Object[] a) {
    System.out.println("B.f(Object[])");
  }
}

class C extends B {

  void f(byte a) {
    System.out.println("C.f(byte)");
  }

  void f(short a) {
    System.out.println("C.f(short)");
  }

  void f(RuntimeException[] a) {
    System.out.println("C.f(RuntimeException[])");
  }

  void f(int[] a) {
    System.out.println("C.f(int[])");
  }

  void f(Object[][] a) {
    System.out.println("C.f(Object[][])");
  }
}
