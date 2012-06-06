/*
1. Compound assign with bool operands:
 - bool &= bool
 - bool |= bool
 - bool ^= bool
*/
public class op_12_bool_compound_assign {
  public static void main(String[] args) {
    boolean b1 = false, b2 = false, b3 = false;
    System.out.println("" + (b1&=true) + " " + (b2|=true) + " " + (b3^=true));
    System.out.println("Done!");
  }
}
