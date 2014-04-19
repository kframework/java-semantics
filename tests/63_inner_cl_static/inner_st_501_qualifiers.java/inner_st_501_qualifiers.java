/*
Inner class qualifiers:
  Classes p1.A, p1.A.Inner,
    - p1.A.Inner.toString().
  Instantiate A.Inner from A as:
    - new p1.A.Inner()
    - new A.Inner()
    - new Inner().
*/

public class inner_st_501_qualifiers {

  public static void main(String[] args) {
    p1.A.test();
    System.out.println("Done!");
  }
}

