/*
B < I1, A. Test cast and instanceof among (A,I1) and (B, I1).
*/

public class interface_11_instof {
  public static void main(String[] args) {
    A a = new A();
    B b = new B();
    System.out.println("A instanceof I1 "+ (a instanceof I1));
    try {
      I1 aux = (I1)a;
      System.out.println("(I1)A ok");
    } catch (ClassCastException e){
      System.out.println("(I1)A exception");
    }
    System.out.println("B instanceof I1 "+ (b instanceof I1));
    try {
      I1 aux = (I1)b;
      System.out.println("(I1)B ok");
    } catch (ClassCastException e){
      System.out.println("(I1)B exception");
    }

    I1 i1 = (I1)b;
    System.out.println("(I1)B instanceof A "+ (i1 instanceof A));
    try {
      A aux = (A)i1;
      System.out.println("(A)(I1)B ok");
    } catch (ClassCastException e){
      System.out.println("(A)(I1)B exception");
    }
    System.out.println("(I1)B instanceof B "+ (i1 instanceof B));
    try {
      B aux = (B)i1;
      System.out.println("(B)(I1)B ok");
    } catch (ClassCastException e){
      System.out.println("(B)(I1)B exception");
    }

    System.out.println("Done!");
  }
}

interface I1 {}

class A {}

class B extends A implements I1 {}
