/*
Binary promotion:
  byte * byte,
  short * short,
  char * char,
  byte * short, short * byte,
  short * int, int * short,
  short * long, long * short,
  int * long, long * int.
  All results representable in no less than promoted type.
*/
public class imp_conv_08_bin_prom_selections {
  public static void main(String[] args) {
    System.out.println(((byte)127)*((byte)127));
    System.out.println(((short)1000)*((short)1000));
    System.out.println(((char)50000)*((char)50000));
    System.out.println(((byte)127)*((short)1000));
    System.out.println(((short)1000)*((byte)127));
    System.out.println(((short)1000)*1234567);
    System.out.println(1234567*((short)1000));
    System.out.println(((short)1000)*123456789L);
    System.out.println(123456789L*((short)1000));
    System.out.println(1000*123456789L);
    System.out.println(1000*123456789L);
    System.out.println("Done!");
  }
}

