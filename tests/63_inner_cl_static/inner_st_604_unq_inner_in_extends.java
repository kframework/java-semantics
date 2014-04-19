/*
Inner class in extends clause.
  Two inner classes. One inherits the other.
  Classes A, A.Inner1, A.Inner2 < Inner1.
  Extends clause refers Inner1 by simple name.
*/

public class inner_st_604_unq_inner_in_extends {

  public static void main(String[] args) {
    System.out.println(new A.Inner2());
    System.out.println("Done!");
  }
}

class A {
  static class Inner1 {
  }

  static class Inner2 extends Inner1 {
    public String toString() {
      return "A.Inner2";
    }
  }
}
