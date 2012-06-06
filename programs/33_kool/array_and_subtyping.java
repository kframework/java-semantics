class A {int f = 1;}
class B extends A {int f = 2;}

public class array_and_subtyping {
  public static void main(String[] args) {
    A[] va = new A[1];
    va[0] = new B();
    System.out.println(va[0].f); //should print 1
    System.out.println("Done!");
  }
}

