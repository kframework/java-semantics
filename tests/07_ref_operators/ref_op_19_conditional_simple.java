/*
obj = true ? "abc" : "def"
obj = false ? "abc" : "def"
*/

public class ref_op_19_conditional_simple {
  public static void main(String[] args) {
    System.out.println((1 < 2) ? "abc" : "def");
    System.out.println((1 > 2) ? "abc" : "def");

    System.out.println("Done!");
  }
}
