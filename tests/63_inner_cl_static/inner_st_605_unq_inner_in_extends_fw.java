/*
Inner class in extends clause, with forward reference.
  Two inner classes. One inherits the other.
  Classes A, A.Inner1 < Inner2, A.Inner2.
  Extends clause refers Inner2 by simple name.
*/

public class inner_st_605_unq_inner_in_extends_fw {

  public static void main(String[] args) {
    System.out.println(new A.Inner1());
    System.out.println("Done!");
  }
}

class A {

  static class Inner1 extends Inner2 {
    public String toString() {
      return "A.Inner1";
    }
  }

  static class Inner2 {
  }
}
