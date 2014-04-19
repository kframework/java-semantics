/*
Implementing an inner interface and name resolution.
  Class A, interface A.IInner1, A.IInner2, B < A.IInner1, A.IInner2.
  Members:
    - static A.x
    - static A.y
    - IInner1.x
    - IInner2.y
  Access:
    - x and y from B
    - B.x, B.y from main.
*/

public class inner_st_807_impl_in_intf_and_names {

  public static void main(String[] args) {
    System.out.println(new B());
    System.out.println(B.x + " " + B.y);

    System.out.println("Done!");
  }
}

class A {

  static String x = "A.x";
  static String y = "A.y";

  interface IInner1 {
    String x = "A.IInner1.x";
  }

  interface IInner2 {
    String y = "A.IInner2.y";
  }
}

class B implements A.IInner1, A.IInner2 {
  public String toString() {
    return "B: x = "+ x + ", y = " + y;
  }
}
