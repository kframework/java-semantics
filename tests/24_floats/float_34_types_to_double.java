/*
Cast types to double: byte, short, int, long, char, float, double to float, without precision loss.
*/

public class float_34_types_to_double {
  public static void main(String[] args) {
    System.out.println("(double) (byte) 100  = " + (double) (byte) 100);
    System.out.println("(double) (short)100  = " + (double) (short)100);
    System.out.println("(double)        100  = " + (double)        100);
    System.out.println("(double)       100L  = " + (double)       100L);
    System.out.println("(double)        'c'  = " + (double)        'c');
    System.out.println("(double)       1.23  = " + (double)       1.23);
    System.out.println("(double)      1.23d  = " + (double)      1.23d);
    System.out.println("Done!");
  }
}
