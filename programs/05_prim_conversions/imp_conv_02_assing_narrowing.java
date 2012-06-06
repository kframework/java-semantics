/*
Assign - narrowing constant int conv:
  int to byte, short, int, long, char
*/
public class imp_conv_02_assing_narrowing {
  public static void main(String[] args) {
    byte b;
    short s;
    int i;
    long l;
    char c;

    //int const to others
    b = 100; s = -1100; i = 1100200; l = 9876543210L; c = 100;
    System.out.println(""+b+" "+s+" "+i+" "+l+" "+c);

    System.out.println("Done!");
  }
}
