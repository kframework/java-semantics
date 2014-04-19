/*
Cast to types: double to byte, short, int, long, char, float, double.
*/

public class float_33_double_to_types {
  public static void main(String[] args) {
    double f1 = 1234567.1;
    System.out.println("         f1  = " +          f1);
    System.out.println("(byte)   f1  = " + (byte)   f1);
    System.out.println("(short)  f1  = " + (short)  f1);
    System.out.println("(int)    f1  = " + (int)    f1);
    System.out.println("(long)   f1  = " + (long)   f1);
    System.out.println("(char)   f1  = " + (char)   (float)90);
    System.out.println("(float)  f1  = " + (float)  f1);
    System.out.println("(double) f1  = " + (double) f1);
    System.out.println("Done!");
  }
}
