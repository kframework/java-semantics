/*
Inner class have a reference to the outer class.
  A, A.B. Members:
  - A: String id
  - A.B: A parent,
  - A.B: toString() (prints parent)
  Instantiate and print A.B.
*/

public class inner_st_201_inner_to_outer {

  public static void main(String[] args) {
    System.out.println(new A.B(new A()));
    System.out.println("Done!");
  }
}

class A {

  String id = "A";

  public String toString() {
    return "A";
  }

  public static class B {

    B(A a) {
      parent = a;
    }

    A parent;

    public String toString() {
      return "A.B, parent.id = " + parent.id;
    }
  }
}
