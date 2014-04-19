/*
Twisted inheritance among outer and inner classes.
  Classes A, A.InnerA < B.InnerB, B < A, B.InnerB.
*/

public class inner_st_711_twisted_inherit {

  public static void main(String[] args) {
    System.out.println(new A.InnerA());
    System.out.println("Done!");
  }
}

class A {
  static class InnerA extends B.InnerB {
    public String toString() {
      return "A.InnerA, base: " + super.toString();
    }
  }
}

class B extends A {
  static class InnerB {
    public String toString() {
      return "B.InnerB";
    }
  }
}
