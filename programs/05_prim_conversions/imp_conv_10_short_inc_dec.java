/*
Byte,short,char increment and decrement:
  ++short, --short, short++, short--, both without and with overflow.
  byte--, char--.

  JLS is ambiguously describing this operators for type short, byte, char.
  According to $4.2.2 ++/-- should be prohibited for those types.
  According to $15.15.1 ++/-- may be applied to any nymeric type var,
    thus is permitted.
*/
public class imp_conv_10_short_inc_dec {
  public static void main(String[] args) {
    short s1 = 0, s2 = 0, s3 = 0, s4 = 0;
    byte b = 0;
    char c = 0;
    ++s1;
    --s2;
    s3++;
    s4--;
    b--;
    c++;
    System.out.println(""+s1+" "+s2+" "+s3+" "+s4+" "+b+" "+(int)c);

    s1 = 32767;
    s2 = -32768;
    s3 = 32767;
    s4 = -32768;
    b = -128;
    c = 0;
    ++s1;
    --s2;
    s3++;
    s4--;
    b--;
    c--;
    System.out.println(""+s1+" "+s2+" "+s3+" "+s4+" "+b+" "+(int)c);

    System.out.println("Done!");
  }
}

