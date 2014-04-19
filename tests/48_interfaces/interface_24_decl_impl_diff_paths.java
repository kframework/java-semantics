/*
Declaration of a method in an interface and it's implementation are both inherited,
  but on different paths.
  Case B < (A, I1). Method f() is declared in I1, implemented by A.
  (Method declared on one path, implemented on other one).
  Add another method implemented by B.
*/

public class interface_24_decl_impl_diff_paths {
  public static void main(String[] args) {
    I1 i1 = new B();
    i1.f();
    i1.g();

    System.out.println("Done!");
  }
}

interface I1 {
  void f();
  void g();
}

class A {
  public void f() {
    System.out.println("A.f()");
  }
}

class B extends A implements I1 {
  public void g() {
    System.out.println("B.g()");
  }
}

