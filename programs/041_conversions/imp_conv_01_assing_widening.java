/*
Assign - widening primitive conv:
  byte to byte, short, int, long
  short to short, int, long
  int to int, long
  long to long
  char to int, long, char
*/
public class imp_conv_01_assing_widening {
  public static void main(String[] args) {
    byte sb, b;
    short ss, s;
    int si, i;
    long sl, l;
    char sc, c;
    sb = (byte)100;
    ss = (short)-1100;
    si = (int)1100200;
    sl = (long)9876543210L;
    sc = (char)'z';

    //byte to others
    b = sb; s = sb; i = sb; l = sb;
    System.out.println(""+b+" "+s+" "+i+" "+l);

    //short to others
    s = ss; i = ss; l = ss;
    System.out.println(""+s+" "+i+" "+l);

    //int to others
    i = si; l = si;
    System.out.println(""+i+" "+l);

    //long to others
    l = sl;
    System.out.println(""+l);

    //char to others
    i = sc; l = sc; c = sc;
    System.out.println(""+i+" "+l+" "+c);

    System.out.println("Done!");
  }
}
