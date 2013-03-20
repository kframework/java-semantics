/*
39. Multi applicable, inheritance simple.	
	A more specific version of the method in the base class.
	- A: f(int)
	- B < A: f(long)
*/

public class overload_39_base_more_specific {

  public static void main(String[] args) {
    A aa = new A(), ab = new B();
    B bb = new B();

    aa.f((int)0);

    ab.f((int)0);

    bb.f((int)0);
    bb.f((long)0);

    System.out.println("Done!");
  }
}

class A {

  void f(int a) {
    System.out.println("A.f(int)");
  }
}

class B extends A {

  void f(long a) {
    System.out.println("B.f(long)");
  }
}
