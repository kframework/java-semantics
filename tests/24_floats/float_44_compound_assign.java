/*
Compound assignment:
  - double += int
  - String += double
*/

public class float_44_compound_assign {
  public static void main(String[] args) {
    double d = 1.2;
    d+=10;
    System.out.println("1.2 += 10: " + d);

    String s = "abc";
    s+=1.2;
    System.out.println("abc += 1.2: " + s);
    System.out.println("Done!");
  }
}
