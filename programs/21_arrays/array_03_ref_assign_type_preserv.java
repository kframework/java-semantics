/*
Array element ref type preservation.
    Check that the type of element of an array of references does not change
    after assigning a value of a narrower reference type.
*/

class A {int f = 1;}
class B extends A {int f = 2;}

public class array_03_ref_assign_type_preserv {
  public static void main(String[] args) {
    A[] va = new A[1];
    va[0] = new B();
    System.out.println(va[0].f); //should print 1
    System.out.println("Done!");
  }
}

